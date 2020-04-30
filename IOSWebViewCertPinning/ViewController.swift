import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var localHTTPSEndpoint = "https://bs-local.com:4443"
    
    override func loadView() {
        webView = SampleWKWebView()
        
        webView.navigationDelegate = self
        view = webView
        webView.loadHTMLString("<html><h2><p><a href='" + localHTTPSEndpoint + "'/>Go to localhost https </a></p></h2></html>", baseURL: nil);
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation){
        print("didStartProvisionalNavigation")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("didReceive challenge")
        
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)
                if(errSecSuccess == status) {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        let serverCertificateData = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData);
                        let size = CFDataGetLength(serverCertificateData);
                        let cert1 = NSData(bytes: data, length: size)
                        let file_der = Bundle.main.path(forResource: "valid_cert", ofType: "der")
                        
                        if let file = file_der {
                            if let cert2 = NSData(contentsOfFile: file) {
                                if cert1.isEqual(to: cert2 as Data) {
                                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
        //Pinning failed
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("Error 'didFail': \(error.localizedDescription)\nSchema: \(String(describing: webView.url?.absoluteString))")
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("Error 'didFailProvisionalNavigation': \(error.localizedDescription)\nSchema: \(String(describing: webView.url?.absoluteString))")
    }

}
