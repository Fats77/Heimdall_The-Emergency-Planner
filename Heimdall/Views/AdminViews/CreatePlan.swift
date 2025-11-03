//
//  CreatePlan.swift
//  Heimdall
//
//  Created by Fatima Zeb on 30/10/25.
//

import SwiftUI

struct CreatePlan: View {
    let columns: [GridItem] = [
        GridItem(.flexible()) , GridItem(.flexible()) ,GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())
    ]
    
    @State private var descText:String = ""
    
    var nums = ["a","b","55","ygyvfyhfyhf"]
    
    var body: some View {
        GeometryReader { geo in
            ScrollView{
                Text ("Select Icon").frame(maxWidth: .infinity , alignment: .leading)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    .padding()
                    .font(.title)
                HStack(){
                    LazyVGrid(columns: columns,spacing: 10) {
                        ForEach(Array(nums).enumerated(), id: \.offset) { index, num in
                            Text("icon \(num)")
                            
                            if index == nums.count-1 {
                                Button{
                                    
                                }
                                label :
                                {
                                    Image(systemName: "plus")
                                        .frame(width: 100, height: 100)
                                        .background(.white)
                                        .cornerRadius(8)
                                        .foregroundStyle(Color.black)
                                        .fontWeight(.bold)
                                        .shadow(color: .gray.opacity(0.5),radius: 5)
                                }
                            }
                        }
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                       
                        .frame(width: geo.size.width / 6, height: geo.size.width / 6)
                        .background(.white)
                        .cornerRadius(8)
                        .shadow(color: .gray.opacity(0.5),radius: 5)
                        
                        
                    }
                    .padding(.horizontal,20)
                }
                
                Text ("Details")
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title)
                    .padding(.leading)
                    .padding(.top,20)
                Spacer()
                
                VStack {
                    Text ("Name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Enter name here", text: $descText)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.white)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.5),radius: 5)
                    Text ("Description")
                        .padding(.top,10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    // TextField("Enter description here", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                    TextEditor(text: $descText)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.white)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.5),radius: 5)
                    
                    
                }
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    CreatePlan()
}
