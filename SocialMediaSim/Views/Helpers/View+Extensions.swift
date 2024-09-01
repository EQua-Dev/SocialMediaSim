//
//  View+Extensions.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 01/09/2024.
//

import SwiftUI


//MARK: View Extensions For UI Building
extension View{
    
    // Closing all active keyboards
    func closeKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    //MARK: Disabling with opacity
    func disableWithOpacity(_ condition: Bool)-> some View{
        self.disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
    
    func hAlign(_ alignment: Alignment)->some View{
        self.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: alignment)
    }
    func vAlign(_ alignment: Alignment)-> some View{
        self.frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: alignment)
    }
    
    //MARK: Custom Border View With Padding
    func border(_ width: CGFloat, _ color: Color) -> some View {
        self
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background{
                RoundedRectangle(cornerRadius: 5, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                    .stroke(color, lineWidth: width)
                
            }
    }
    
    //MARK: Custom Background View With Padding
    func fillView( _ color: Color) -> some View {
        self
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background{
                RoundedRectangle(cornerRadius: 5, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                    .fill(color)
                
            }
    }
}




