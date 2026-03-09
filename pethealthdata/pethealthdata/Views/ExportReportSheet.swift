import SwiftUI
import SwiftData

struct ExportReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let pet: Pet
    
    @State private var selectedDateRange: PDFExportService.DateRange = .allTime
    @State private var isGenerating: Bool = false
    @State private var generatedPDF: Data?
    @State private var showingShareSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.appPrimary)
                    
                    Text("Export Health Report")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    
                    Text("Generate a PDF report of \(pet.name)'s health records to share with your veterinarian")
                        .font(.system(size: 15))
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Date Range")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                        .padding(.horizontal)
                    
                    ForEach(PDFExportService.DateRange.allCases) { range in
                        Button {
                            selectedDateRange = range
                        } label: {
                            HStack {
                                Image(systemName: selectedDateRange == range ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedDateRange == range ? .appPrimary : .appTextSecondary)
                                
                                Text(range.rawValue)
                                    .font(.system(size: 16))
                                    .foregroundColor(.appTextPrimary)
                                
                                Spacer()
                            }
                            .padding()
                            .background(selectedDateRange == range ? Color.appPrimary.opacity(0.1) : Color.appCardBackground)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                if let pdfData = generatedPDF {
                    Button {
                        showingShareSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share PDF")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.appPrimary)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                } else {
                    Button {
                        generatePDF()
                    } label: {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "doc.badge.plus")
                                Text("Generate PDF")
                            }
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.appPrimary)
                        .cornerRadius(12)
                    }
                    .disabled(isGenerating)
                    .padding(.horizontal)
                }
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfData = generatedPDF {
                    ShareSheet(items: [pdfData])
                }
            }
        }
    }
    
    private func generatePDF() {
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let pdfData = PDFExportService.shared.generateHealthReport(for: pet, dateRange: selectedDateRange)
            
            DispatchQueue.main.async {
                generatedPDF = pdfData
                isGenerating = false
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

@available(iOS 17.0, *)
#Preview {
    ExportReportSheet(pet: Pet(name: "Buddy", species: "dog"))
}
