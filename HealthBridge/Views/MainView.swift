import SwiftUI
import UIKit

private let brand = Color(red: 0.03, green: 0.47, blue: 0.54)

@MainActor
struct MainView: View {
    @ObservedObject var model: ExportViewModel
    @State private var tab: Tab = .export
    @Environment(\.scenePhase) private var scenePhase

    enum Tab { case export, integration, settings }

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                ExportScreen(model: model, openIntegration: { tab = .integration })
                    .navigationTitle("HealthBridge")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Aktarım", systemImage: "square.and.arrow.up") }
            .tag(Tab.export)

            NavigationStack {
                IntegrationScreen(model: model, openExport: { tab = .export })
                    .navigationTitle("API bağlantısı")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Bağlantı", systemImage: "point.3.connected.trianglepath.dotted") }
            .tag(Tab.integration)

            NavigationStack {
                PrivacyScreen(model: model)
                    .navigationTitle("Ayarlar")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Ayarlar", systemImage: "gearshape") }
            .tag(Tab.settings)
        }
        .tint(brand)
        .alert("HealthBridge", isPresented: Binding(
            get: { model.alert != nil },
            set: { if !$0 { model.alert = nil } }
        )) {
            Button("Tamam", role: .cancel) { model.alert = nil }
        } message: { Text(model.alert ?? "") }
        .sheet(item: $model.sharedFile) { file in
            ShareSheet(url: file.url) {
                ExportService.removeFile(file.url)
            }
            .presentationDetents([.medium, .large])
        }
        // Mask sensitive preview while the system snapshots the app switcher.
        .overlay {
            if scenePhase != .active {
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .overlay {
                        VStack(spacing: 12) {
                            Image(systemName: "lock.shield.fill").font(.system(size: 40))
                            Text("HealthBridge").font(.headline)
                        }.foregroundStyle(brand)
                    }
                    .allowsHitTesting(false)
            }
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let url: URL
    let didFinish: () -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let view = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        view.completionWithItemsHandler = { _, _, _, _ in didFinish() }
        return view
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

@MainActor
private struct ExportScreen: View {
    @ObservedObject var model: ExportViewModel
    let openIntegration: () -> Void
    private let ranges = [7, 30, 90]
    @State private var showEmptyMetrics = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                dates
                metrics
                prepare
                if let export = model.export { preview(export) }
            }
            .padding(18)
            .frame(maxWidth: 650)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Label("Yerel işleme", systemImage: "lock.shield")
                    .font(.caption.weight(.semibold))
                    .padding(8)
                    .background(.white.opacity(0.15), in: Capsule())
            }
            Text("Sağlık verilerin,\nsenin kontrolünde.")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)
            Text("Apple Sağlık kayıtlarını seç, önizle ve istediğin uyumlu hizmete aktar.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.88))
            HStack {
                Text("\(model.selected.count) veri türü seçili")
                Spacer()
                Text(model.permissionRequested ? "İzin isteği yapıldı" : "İzin henüz istenmedi")
            }
            .font(.caption.weight(.medium))
            .padding(.top, 4)
        }
        .foregroundStyle(.white)
        .padding(22)
        .background(LinearGradient(colors: [brand, Color(red: 0.06, green: 0.29, blue: 0.39)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 24))
    }

    private var dates: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Tarih aralığı", icon: "calendar")
            HStack(spacing: 8) {
                ForEach(ranges, id: \.self) { days in
                    Button("Son \(days) gün") { model.setRange(days: days) }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                }
            }
            DatePicker("Başlangıç", selection: $model.startDate, in: ...Date(), displayedComponents: .date)
            Divider()
            DatePicker("Bitiş", selection: $model.endDate, in: ...Date(), displayedComponents: .date)
            Text("Başlangıç ve bitiş günleri dahildir.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .cardStyle()
        .disabled(model.busy)
    }

    private var metrics: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle("Veri türleri", icon: "heart.text.clipboard")
                Spacer()
                Button(model.selected.count == HealthMetric.available.count ? "Temizle" : "Tümü (\(HealthMetric.available.count))") {
                    model.selected = model.selected.count == HealthMetric.available.count ? [] : Set(HealthMetric.available)
                }.font(.subheadline.weight(.medium))
            }
            ForEach(MetricGroup.allCases) { group in
                MetricGroupView(group: group, model: model)
                if group != MetricGroup.allCases.last { Divider() }
            }
            Text("Sadece seçilen ve iOS sürümünün desteklediği türler için okuma izni istenir. Huawei ve Xiaomi kayıtları da dahildir. GPS rotaları ve belirtiler gibi hassas türleri yalnızca paylaşmak istiyorsan seç.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .cardStyle()
        .disabled(model.busy)
    }

    private var prepare: some View {
        VStack(spacing: 10) {
            Button {
                Task { await model.prepare() }
            } label: {
                Label(model.busy && model.export == nil ? "Kayıtlar hazırlanıyor…" : "Verileri hazırla",
                      systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .disabled(model.busy || model.selected.isEmpty)
            if model.busy && model.export == nil {
                ProgressView(value: model.progress)
                Text("Apple Sağlık kayıtları okunuyor…").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func preview(_ export: HealthExport) -> some View {
        let counts = export.counts
        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    sectionTitle("Aktarım önizlemesi", icon: "checkmark.shield")
                    Text("\(export.records.count.formatted()) kayıt")
                        .font(.system(.title, design: .rounded, weight: .bold))
                }
                Spacer()
                Button("Temizle", role: .destructive) { model.invalidatePreview() }
                    .font(.caption)
                    .disabled(model.busy)
            }
            ForEach(HealthMetric.allCases.filter { export.selectedMetrics.contains($0.rawValue) && (showEmptyMetrics || (counts[$0.rawValue] ?? 0) > 0) }) { metric in
                HStack {
                    Text(metric.title).font(.subheadline)
                    Spacer()
                    Text((counts[metric.rawValue] ?? 0).formatted())
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            let emptyCount = export.selectedMetrics.filter { (counts[$0] ?? 0) == 0 }.count
            if emptyCount > 0 {
                Button(showEmptyMetrics ? "Boş türleri gizle" : "Kaydı olmayan \(emptyCount) türü göster") {
                    showEmptyMetrics.toggle()
                }.font(.caption.weight(.medium))
            }
            if let issues = export.readIssues, !issues.isEmpty {
                Label("\(issues.count) tür okunamadı; bu türler aktarılmadı.", systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline.weight(.semibold)).foregroundStyle(.orange)
                ForEach(HealthMetric.available.filter { issues[$0.rawValue] != nil }) { metric in
                    Text(metric.title).font(.caption).foregroundStyle(.secondary)
                }
            }
            Text("Ham kayıtlardır; farklı kaynakların örtüşen ölçümleri korunur. 0 kayıt, ölçüm bulunmadığı veya okuma izni verilmediği anlamına gelebilir.")
                .font(.caption).foregroundStyle(.secondary)
            Divider()
            Picker("Dosya biçimi", selection: $model.format) {
                ForEach(ExportFormat.allCases) { format in Text(format.rawValue).tag(format) }
            }
            .pickerStyle(.segmented)
            .disabled(model.busy)
            Text(model.format.detail).font(.caption).foregroundStyle(.secondary)
            if model.format == .csv, export.records.contains(where: { $0.details?.points != nil }) {
                Text("EKG, rota ve diğer seri verileri için JSON önerilir; bazı tablo uygulamaları uzun hücreleri kısaltabilir.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Button { model.makeShareFile() } label: {
                Label("Dosyayı paylaş", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity).padding(.vertical, 5)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!model.ready)

            Button(action: openIntegration) {
                Label("API ile aktar", systemImage: "arrow.up.right")
                    .frame(maxWidth: .infinity).padding(.vertical, 5)
            }
            .buttonStyle(.bordered)
            .disabled(!model.ready)

            Text("Paylaşımı yalnızca güvendiğin ve verilerini işlemeyi kabul ettiğin sağlık hizmetlerine yap. Oluşturulan dosyada hassas kişisel bilgiler bulunur.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .cardStyle()
    }
}

@MainActor
private struct MetricGroupView: View {
    let group: MetricGroup
    @ObservedObject var model: ExportViewModel
    @State private var expanded = false
    private var metrics: [HealthMetric] { HealthMetric.available.filter { $0.group == group } }
    private var count: Int { metrics.filter { model.selected.contains($0) }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
            } label: {
                HStack {
                    Image(systemName: group.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(brand)
                        .frame(width: 36, height: 36)
                        .background(brand.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                    Text(group.rawValue).font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(count)/\(metrics.count)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(group.rawValue), \(count) seçili")
            if expanded {
                Button(count == metrics.count ? "Grubu temizle" : "Grubun tümünü seç") {
                    model.selectAll(in: group)
                }
                .font(.caption.weight(.medium))
                ForEach(metrics) { metric in
                    Toggle(isOn: Binding(
                        get: { model.selected.contains(metric) },
                        set: { value in
                            if value { model.selected.insert(metric) }
                            else { model.selected.remove(metric) }
                        }
                    )) { Text(metric.title).font(.subheadline) }
                }
            }
        }
    }
}

@MainActor
private struct IntegrationScreen: View {
    @ObservedObject var model: ExportViewModel
    let openExport: () -> Void
    @State private var confirmReset = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.system(size: 34)).foregroundStyle(brand)
                    Text("Hizmetine bağlan").font(.title2.bold())
                    Text("JSON alan ve sağlık verilerini kabul etmeye yetkili bir HTTPS uç noktasıyla çalışır. Sağlık hizmetinin kendi API adresini ve gerekiyorsa Bearer anahtarını gir.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("Bağlantı bilgileri", icon: "link")
                    Text("HTTPS uç noktası").font(.caption.weight(.semibold))
                    TextField("https://example.com/api/health", text: $model.endpoint)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder)
                    Text("Bearer anahtarı (isteğe bağlı)").font(.caption.weight(.semibold))
                    SecureField("Erişim anahtarı", text: $model.token)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    Button("Bağlantıyı kaydet") { model.saveConnection() }
                        .buttonStyle(.bordered)
                    Button("Bağlantıyı kaldır", role: .destructive) { confirmReset = true }
                        .font(.caption)
                    Text("Anahtar bu iPhone'un Keychain alanında saklanır. Kaydetme işlemi veri göndermez.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .cardStyle()
                .disabled(model.busy)

                VStack(alignment: .leading, spacing: 14) {
                    sectionTitle("Gönderim", icon: "paperplane")
                    if model.ready || (model.busy && model.export != nil) {
                        Text("\(model.recordCount.formatted()) kayıt • JSON")
                            .font(.title3.bold())
                        if let url = try? EndpointValidator.url(from: model.endpoint) {
                            Text("Hedef: \(url.absoluteString)")
                                .font(.caption).textSelection(.enabled)
                                .foregroundStyle(.secondary)
                        }
                        Toggle("Bu hedefin bir sağlık/fitness hizmeti olduğunu ve seçilen sağlık verilerimi işlemesini onaylıyorum.", isOn: $model.consent)
                            .font(.subheadline)
                            .disabled(model.busy)
                        Button {
                            Task { await model.send() }
                        } label: {
                            Label(model.busy ? "Gönderiliyor…" : "Onayla ve gönder", systemImage: "paperplane.fill")
                                .frame(maxWidth: .infinity).padding(.vertical, 6)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!model.ready || !model.consent || (try? EndpointValidator.url(from: model.endpoint)) == nil)
                        if model.busy { ProgressView() }
                    } else {
                        Text("Henüz aktarılmaya hazır kayıt yok. Önce Aktarım ekranından verileri hazırla.")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Button("Aktarım ekranına dön", action: openExport)
                            .buttonStyle(.bordered)
                    }
                    if let status = model.apiStatus {
                        Label(status, systemImage: "checkmark.circle.fill")
                            .font(.subheadline).foregroundStyle(.green)
                    }
                    Text("Gönderim yalnızca bu düğmeye bastığında yapılır. Başarılı HTTP yanıtı, hedefin verileri doğru şekilde işlediğini tek başına garanti etmez.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .cardStyle()
            }
            .padding(18)
            .frame(maxWidth: 650)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .confirmationDialog("Bağlantı ayarları silinsin mi?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Bağlantıyı sil", role: .destructive) { model.clearConnection() }
            Button("Vazgeç", role: .cancel) {}
        }
    }
}

@MainActor
private struct PrivacyScreen: View {
    @ObservedObject var model: ExportViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "lock.shield.fill").font(.system(size: 38)).foregroundStyle(brand)
                    Text("Gizlilik önce gelir.").font(.title2.bold())
                    Text("HealthBridge Apple Sağlık'taki verileri değiştirmez, reklam veya analiz amaçlı kullanmaz; hesabı, takipçiyi ya da kendi sunucusunu gerektirmez.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("Veri ve izin yönetimi", icon: "checkmark.shield")
                    Text("Okuma izinleri Apple Sağlık > profil > Uygulamalar bölümünden değiştirilebilir. HealthKit, reddedilen okuma izinlerini uygulamaya açıklamaz.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Button("Hazırlanan verileri bellekte temizle", role: .destructive) { model.invalidatePreview() }
                        .disabled(model.busy)
                    Button("Geçici aktarım dosyalarını temizle", role: .destructive) { ExportService.clearTemporaryExports() }
                        .disabled(model.busy || model.sharedFile != nil)
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("Gizlilik politikası", icon: "doc.text")
                    Text("Seçilen ölçümler RAM'de işlenir. Dışa aktarma sırasında geçici, cihaz kilidiyle korunan dosya oluşturulur. Dosyayı paylaştığında veya API gönderimini onayladığında seçilen alıcıya veri aktarılır. Hedef hizmetin saklama ve silme politikaları ayrıdır.")
                        .font(.subheadline)
                    Text("API aracında HTTPS ve standart sistem güven doğrulaması kullanılır; yönlendirmeler reddedilir. Bağlantı URL'si cihaz ayarlarında, anahtar Keychain'de saklanır. Sağlık kayıtları iCloud'a veya uygulamaya ait bir veritabanına yazılmaz.")
                        .font(.subheadline)
                    Text("Sürüm 1.1 • HealthBridge").font(.caption).foregroundStyle(.secondary)
                }
                .cardStyle()
            }
            .padding(18)
            .frame(maxWidth: 650)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
    }
}

private func sectionTitle(_ title: String, icon: String) -> some View {
    Label(title, systemImage: icon)
        .font(.headline)
        .foregroundStyle(.primary)
}

private extension View {
    func cardStyle() -> some View {
        self.padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}
