//
//  PrintersSectionView.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 4/15/24.
//
/*
import SwiftUI

struct PrintersSectionView: View {
    @Binding var viewModel: SiteReadySurveyView.ViewModel
    
    var body: some View {
        Section(header: Text("Printers")) {
            // How many B&W printers are there?
            Section(header: Text("How many B&W printers are there?")) {
                TextField("Enter B&W printer count", value: $viewModel.bwPrinterCount, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
            }
            
            // How many color printers are there?
            Section(header: Text("How many color printers are there?")) {
                TextField("Enter color printer count", value: $viewModel.colorPrinterCount, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
            }
            
            // Top off all printers with paper
            if viewModel.showPrinterRelatedSections {
                Section(header: Text("Top off all printers with paper")) {
                    Toggle(isOn: $viewModel.topOffPrintersWithPaper) {
                        Text(viewModel.topOffPrintersWithPaper ? "Yes" : "No")
                    }
                }
            }
            
            // Do any printer labels need replacement?
            if viewModel.showPrinterRelatedSections && viewModel.topOffPrintersWithPaper {
                Section(header: Text("Do any printer labels need replacement?")) {
                    Toggle(isOn: $viewModel.needPrinterLabelReplacement) {
                        Text(viewModel.needPrinterLabelReplacement ? "Yes" : "No")
                    }
                    if viewModel.needPrinterLabelReplacement {
                        VStack {
                            Stepper(value: $viewModel.printerLabelsToReplace, in: 0...100, step: 1) {
                                Text("How many printer labels need to be replaced? \(viewModel.printerLabelsToReplace)")
                            }
                            
                            if viewModel.printerLabelsToReplace > 0 {
                                ForEach(0..<viewModel.printerLabelsToReplace, id: \.self) { index in
                                    PrinterLabelReplacementView(labelIndex: index, printerLabel: $viewModel.printerLabels[index])
                                }
                            }
                        }
                    }
                }
                
                // Did you test print a page for each printer?
                Section(header: Text("Did you test print a page for each printer?")) {
                    Toggle(isOn: $viewModel.testPrintedForPrinters) {
                        Text(viewModel.testPrintedForPrinters ? "Yes" : "No")
                    }
                }
                
                // Did you wipe down each printer?
                Section(header: Text("Did you wipe down each printer?")) {
                    Toggle(isOn: $viewModel.wipedDownPrinters) {
                        Text(viewModel.wipedDownPrinters ? "Yes" : "No")
                    }
                }
            }
        }
    }
}

struct PrinterLabelReplacementView: View {
    var labelIndex: Int
    @Binding var printerLabel: String
    
    var body: some View {
        HStack {
            Text("Label \(labelIndex + 1):")
            TextField("Enter Label Name", text: $printerLabel)
        }
    }
}
 /**/*/
