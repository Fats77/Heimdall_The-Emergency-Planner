//
//  MemberDetailView.swift
//  Heimdall
//
//  Created by Fatima Zeb on 12/11/25.
//

import SwiftUI

struct MemberDetailView: View {
    var body: some View {
        
        VStack{
            
            HStack(){
                
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height:50)
                    .clipShape(Circle())
                    .padding(.bottom,10)
                
                VStack(alignment: .leading){
                    
                    Text("John Doe")
                    Text("johndoe.123@gmail.com")
                        .tint(.black)
                  
                }
                .padding(.leading)
                Spacer()
                Button{
                }
                label: {
                  //  Text("Remove")
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                } .tint(.white)
                    .padding(7)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
              
            }
            
           
            HStack (){
                Text("Role")
                    .foregroundStyle(.secondary)
               
                Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: Text("Select Role")) {
                    Text("Member").tag(1)
                    Text("Admin").tag(2)
                    Text("Coordinator").tag(3)
                    
                }
                .tint(.black)
              
            }
            Spacer()
            
        }
        .padding()
        
        
    }
        
        
}


#Preview {
    MemberDetailView()
}
