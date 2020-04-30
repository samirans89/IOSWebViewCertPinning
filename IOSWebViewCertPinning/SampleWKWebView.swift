import WebKit

public class SampleWKWebView: WKWebView {


    public override init(frame: CGRect, configuration: WKWebViewConfiguration = WKWebViewConfiguration()) {
        super.init(frame: frame, configuration: configuration)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}

