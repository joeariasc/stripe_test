//
//  CheckoutViewController.swift
//  Runner
//
//  Created by Joe Arias on 8/02/24.
//

import UIKit
import StripePaymentSheet

class CheckoutViewController: UIViewController {
    
    
    private var paymentIntentClientSecret: String?
    
    var stripePublishableKey: String!
    var amount: String!
    var serverHost: String!
    var cartItems: [[String]] = []
    var result: FlutterResult!
    private lazy var backendURL = URL(string: serverHost)!
    private var tableView: UITableView!
    
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
        setupTableView()
        StripeAPI.defaultPublishableKey = stripePublishableKey
        
        view.backgroundColor = .systemBackground
        view.addSubview(payButton)
        view.addSubview(tableView)
        
        setupConstraints()
        
        
        self.fetchPaymentIntent()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            payButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -20)
        ])
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Register a simple UITableViewCell for your content
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ItemCell")
    }
    
    func fetchPaymentIntent() {
        let url = backendURL.appendingPathComponent("/api/payment")
        
        let shoppingCartContent: [String: Any] = [
            "items": [
                ["id": "xl-shirt"]
            ],
            "amount": amount
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
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                    appDelegate.stripeChannel.invokeMethod("paymentSuccess", arguments: nil)
                }
                strongSelf.navigationController?.popViewController(animated: true)
            }))
            strongSelf.present(alertController, animated: true)
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

extension CheckoutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return cartItems.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
            
            let item = cartItems[indexPath.row]
            cell.textLabel?.text = "\(item[0]): $\(item[1])"
            
            return cell
        }
}
