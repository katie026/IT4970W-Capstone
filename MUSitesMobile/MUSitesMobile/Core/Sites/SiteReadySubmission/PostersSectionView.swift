//
//  PostersSectionView.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 4/15/24.
//
/*
import SwiftUI

struct PosterSectionView: View {
    @ObservedObject var viewModel: SiteReadySurveyView.ViewModel
    
    var body: some View {
        Section(header: Text("Posters")) {
            // Mission Statement banner
            Picker("Is the Mission Statement banner on the poster board?", selection: $viewModel.missionStatementBanner) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Reserved Board notification
            Picker("Is the Reserved Board notification on the poster board?", selection: $viewModel.reservedBoardNotification) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Cyber Security poster
            Picker("Is the Cyber Security poster on the poster board?", selection: $viewModel.cyberSecurityPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Adaptive Computing poster
            Picker("Is the Adaptive Computing poster on the poster board?", selection: $viewModel.adaptiveComputingPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // PrintSmart Printing Information poster
            Picker("Is the PrintSmart Printing Information poster on the poster board?", selection: $viewModel.printSmartPrintingInfoPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Need Help? poster
            Picker("Is one of these Need Help? posters on the poster board?", selection: $viewModel.needHelpPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Active Shooter poster
            Picker("Is the Active Shooter poster on the poster board?", selection: $viewModel.activeShooterPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Emergency Procedures poster
            Picker("Is the Emergency Procedures poster on the poster board?", selection: $viewModel.emergencyProceduresPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // CopyRight/Wrong poster
            Picker("Is the CopyRight/Wrong poster on the poster board?", selection: $viewModel.copyRightWrongPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // SAS/SPSS poster
            Picker("Is the SAS/SPSS poster on the poster board?", selection: $viewModel.sasSpssPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // New Adobe CC Login poster
            Picker("Is the New Adobe CC Login poster on the poster board?", selection: $viewModel.newAdobeCcLoginPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            Section(header: Text("Removed any other posters on the board that were not mentioned above")) {
                Toggle(isOn: $viewModel.otherPostersRemoved) {
                    Text(viewModel.otherPostersRemoved ? "Yes" : "No")
                }
            }
            
            Section(header: Text("8.5 x 11\" Sign Holders Outside the Door")) {
                Toggle(isOn: $viewModel.signHoldersGoodCondition) {
                    Text(viewModel.signHoldersGoodCondition ? "Yes" : "No")
                }
                
                if !viewModel.signHoldersGoodCondition {
                    TextField("Enter sign holder condition", text: $viewModel.signHolderCondition)
                }
            }
        }
    }
}
 /**/*/
