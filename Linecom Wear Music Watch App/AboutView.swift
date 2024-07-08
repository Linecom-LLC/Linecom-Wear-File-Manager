//
//  AboutView.swift
//  Linecom Wear FM Watch App
//
//  Created by 澪空 on 2024/7/9.
//

import SwiftUI
import AuthenticationServices

struct AboutView: View{
    //@AppStorage("debugselect") var debug=false
    //@State var ICPPersent=false
    //@State var LicensePersent=false
    //@State var debugmodepst=false
    var body: some View{
        VStack{
            HStack{
                Image("abouticon").resizable().scaledToFit().mask{Circle()}
                
                VStack{
                    Text("澪空软件")
                    Text("腕上文件")
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
                }.padding()
            }
                Text("Developed by Linecom").padding().onTapGesture {
                    let session = ASWebAuthenticationSession(url: URL(string: "https://www.linecom.net.cn")!, callbackURLScheme: "mlhd") { _, _ in
                        return
                    }
                    session.prefersEphemeralWebBrowserSession = true
                    session.start()
                }
        }
    }
}

#Preview {
    AboutView()
}
