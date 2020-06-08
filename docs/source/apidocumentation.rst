.. |br| raw:: html

   <br />


Setting up ClubKit
---------------------------------------

There are four functions used in setting up the ClubKit singleton:

.. code-block:: Swift

  // Set the delegate for CaptureMiddlewareDelegate
  @discardableResult
  public func setDelegate(to: CaptureMiddlewareDelegate) -> Club

  // Set the DispatchQueue by which SKTCapture delegate
  // functions will be invoked on
  @discardableResult
  public func setDispatchQueue(_ queue: DispatchQueue) -> Club

  // Toggles whether debug messages will be logged
  // to the DebugLogger object
  @discardableResult
  public func setDebugMode(isActivated: Bool) -> Club

  // Open the SKTCapture layer with credentials.
  // This is required for proper use of BLE devices in the desired app.
  public func open(withAppKey appKey: String, appId: String, developerId: String, completion: ((CaptureLayerResult) -> ())? = nil)




Putting it all together
-----------------------


.. code-block:: Swift

  // Import ClubKit to use the cocoapod and its delegates
  import ClubKit




  override func viewDidLoad() {
      super.viewDidLoad()
      setupClub()
  }

  // Step TWO
  // Setup the Club singleton. NOTE, this does not need to be initialized again.
  // It can be used anywhere in your application afterward.
  private func setupClub() {
    // Use the values provided when you registered your application on the Socket Mobile developer site.
    // This is necessary to using ClubKit and Capture together.
    let appKey =        <Your app key>
    let appId =         <Your app ID>
    let developerId =   <Your developer ID>

    Club.shared.setDelegate(to: self)
        .setDispatchQueue(DispatchQueue.main)
        .setDebugMode(isActivated: true)
        .open(withAppKey:   appKey,
              appId:        appId,
              developerId:  developerId,
              completion: { (result) in

                if result != CaptureLayerResult.E_NOERROR {
                    // Open failed due to internal error.
                    // Display an alert to the user suggesting to restart the app
                    // or perform some other action.
                }
         })
  }








Optional Features
-----------------

Extending the CaptureMiddleware delegate
-----------------------------

.. code-block:: Swift

  // MARK: - CaptureMiddlewareDelegate

  extension ViewController: CaptureMiddlewareDelegate {

    func capture(_ middleware: CaptureMiddleware, didNotifyArrivalForManager deviceManager: CaptureLayerDeviceManager, result: CaptureLayerResult) {

        deviceManager.dispatchQueue = DispatchQueue.main

        // By default, the favorites is set to ""
        deviceManager.getFavoriteDevicesWithCompletionHandler { (result, favorite) in
            if result == CaptureLayerResult.E_NOERROR {
                if let favorite = favorite, favorite == "" {
                    deviceManager.setFavoriteDevices("*") { (result) in

                    }
                }
            }
        }
    }

    func capture(_ middleware: CaptureMiddleware, didNotifyRemovalForManager deviceManager: CaptureLayerDeviceManager, result: CaptureLayerResult) {

    }

    func capture(_ middleware: CaptureMiddleware, didNotifyArrivalFor device: CaptureLayerDevice, result: CaptureLayerResult) {

        // Update UI if necessary
    }

    func capture(_ middleware: CaptureMiddleware, didNotifyRemovalFor device: CaptureLayerDevice, result: CaptureLayerResult) {

        // Update UI if necessary
    }

    func capture(_ middleware: CaptureMiddleware, batteryLevelDidChange value: Int, for device: CaptureLayerDevice) {

        // Update UI if necessary
    }

    func capture(_ middleware: CaptureMiddleware, didReceive decodedData: CaptureLayerDecodedData?, for device: CaptureLayerDevice, withResult result: CaptureLayerResult) {

        // NOTE
        // Pass the data obtained from scanning the mobile pass, RFID cards, etc.
        // to the middleware (the Club object is the default but you may subclass your own CaptureMiddleware)
        // This will handle the loyalty / membership state of the user

        if let error = Club.shared.onDecodedData(decodedData: decodedData, device: device) {
            print("Error reading decoded data: \(error.localizedDescription)")
        }

        // Update UI if necessary
    }

  }








Displaying and observing changes to `MembershipUsers`
-------------------------------------------

.. code-block:: Swift

  // Create a `MembershipUserCollection` object which contain a list of all currently stored users
  let usersCollection = MembershipUserCollection()

  override func viewDidLoad() {
      super.viewDidLoad()

      loadAndObserveAllRecords()
  }

  func loadAndObserveAllRecords() {

        usersCollection.observeAllRecords({ [weak self] (changes: MembershipUserChanges) in
            guard let strongSelf = self else { return }

            switch changes {
            case .initial(_):
                // Reload the tableView (or UICollectionView) for initial state
                strongSelf.tableView.reloadData()

            case let .update(_, deletions, insertions, modifications):

                // Handle tableView (or UICollectionView) deletions, insertions and updates

                strongSelf.tableView.performBatchUpdates({
                    strongSelf.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    strongSelf.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    strongSelf.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                }, completion: { (completed: Bool) in
                    strongSelf.tableView.reloadData()
                })
                break
            case let .error(error):

                // Handle possible errors
                print(error.localizedDescription)
            }

        })
    }



    extension ViewController: UITableViewDelegate, UITableViewDataSource {

        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return usersCollection.users.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let user = usersCollection.users[indexPath.item]

            // Configure cell UI with information of the user...
        }

        // Other UITableViewDelegate and UITableViewDataSource functions ...

    }
