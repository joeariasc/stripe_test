//
//  CheckoutViewController.swift
//  Runner
//
//  Created by Joe Arias on 8/02/24.
//

import UIKit
import StripePaymentSheet

class CheckoutViewController: UIViewController {
    
    private static let backendURL = URL(string: "http://localhost:3000")!
    private var paymentIntentClientSecret: String?
    
    var stripePublishableKey: String!
    var result: FlutterResult!
    
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Pay now", for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 5
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        StripeAPI.defaultPublishableKey = stripePublishableKey //"pk_test_51OgVTmH7FzagETwqhZyfZMuo4eWHEkQAiAcwPgv5zH1x65ErSWQWnkpu4vasErhCYGn8VQJykW3UcYQSuIwPGSoi00cvQeqNsF"
        
        view.backgroundColor = .systemBackground
        view.addSubview(payButton)
        
        NSLayoutConstraint.activate([
            payButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        
        self.fetchPaymentIntent()
    }
    
    func fetchPaymentIntent() {
        let url = Self.backendURL.appendingPathComponent("/api/payment")
        
        let shoppingCartContent: [String: Any] = [
            "items": [
                ["id": "xl-shirt"]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: shoppingCartContent)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let clientSecret = json["clientSecret"] as? String
            else {
                let message = error?.localizedDescription ?? "Failed to decode response from server."
                self?.displayAlert(title: "Error loading page", message: message)
                return
            }
            
            print("Created PaymentIntent")
            self?.paymentIntentClientSecret = clientSecret
            
            DispatchQueue.main.async {
                self?.payButton.isEnabled = true
            }
        })
        
        task.resume()
    }
    
    func displayAlert(title: String, message: String? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }
    
    @objc
    func pay() {
        guard let paymentIntentClientSecret = self.paymentIntentClientSecret else {
            return
        }
        
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Example, Inc."
        
        
        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: paymentIntentClientSecret,
            configuration: configuration)
        
        paymentSheet.present(from: self) { [weak self] (paymentResult) in
            switch paymentResult {
            case .completed:
                self?.displayAlert(title: "Payment complete!")
            case .canceled:
                print("Payment canceled!")
            case .failed(let error):
                self?.displayAlert(title: "Payment failed", message: error.localizedDescription)
            }
        }
    }
}
