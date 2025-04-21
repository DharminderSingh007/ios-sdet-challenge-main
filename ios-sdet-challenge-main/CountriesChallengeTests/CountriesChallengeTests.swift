//
//  CountriesChallengeTests.swift
//  CountriesChallengeTests
//

import XCTest
@testable import CountriesChallenge

class CountriesChallengeTests: XCTestCase {

    override func setUpWithError() throws {
        // Common setup for all tests
        // Create shared test objects that can be reused across tests
        testCountry = Country(
            name: "Test Country", 
            alpha2Code: "TC", 
            alpha3Code: "TCY", 
            capital: "Capital", 
            region: "Region", 
            population: 1000, 
            currencies: [Currency(code: "USD", name: "Dollar", symbol: "$")], 
            languages: [Language(name: "English", nativeName: "English")]
        )
        
        testService = CountriesService()
        testViewModel = CountriesViewModel(service: testService)
    }

    override func tearDownWithError() throws {
        // Clean up objects after tests
        testCountry = nil
        testService = nil
        testViewModel = nil
    }
    
    // Common test fixtures
    var testCountry: Country!
    var testService: CountriesService!
    var testViewModel: CountriesViewModel!
    
    // MARK: - Basic Sanity Tests
    
    func testTestFixturesExist() {
        // Verify that our test fixtures are properly set up
        XCTAssertNotNil(testCountry, "Test country should exist")
        XCTAssertNotNil(testService, "Test service should exist")
        XCTAssertNotNil(testViewModel, "Test view model should exist")
    }

    // MARK: - Model Tests
    
    func testCountryModel() {
        let country = Country(name: "Test Country", alpha2Code: "TC", alpha3Code: "TCY", capital: "Capital", region: "Region", population: 1000, currencies: [Currency(code: "USD", name: "Dollar", symbol: "$")], languages: [Language(name: "English", nativeName: "English")])
        
        XCTAssertEqual(country.name, "Test Country")
        XCTAssertEqual(country.alpha2Code, "TC")
        XCTAssertEqual(country.alpha3Code, "TCY")
        XCTAssertEqual(country.capital, "Capital")
        XCTAssertEqual(country.region, "Region")
        XCTAssertEqual(country.population, 1000)
        XCTAssertEqual(country.currencies.count, 1)
        XCTAssertEqual(country.languages.count, 1)
    }
    
    func testCurrencyModel() {
        let currency = Currency(code: "USD", name: "Dollar", symbol: "$")
        
        XCTAssertEqual(currency.code, "USD")
        XCTAssertEqual(currency.name, "Dollar")
        XCTAssertEqual(currency.symbol, "$")
    }
    
    func testLanguageModel() {
        let language = Language(name: "English", nativeName: "English")
        
        XCTAssertEqual(language.name, "English")
        XCTAssertEqual(language.nativeName, "English")
    }
    
    // MARK: - Parser Tests
    
    func testParserSuccess() {
        let parser = CountriesParser()
        
        // Create a sample valid JSON
        let json = """
        [
            {
                "name": "Test Country",
                "alpha2Code": "TC",
                "alpha3Code": "TCY",
                "capital": "Capital",
                "region": "Region",
                "population": 1000,
                "currencies": [
                    {
                        "code": "USD",
                        "name": "Dollar",
                        "symbol": "$"
                    }
                ],
                "languages": [
                    {
                        "name": "English",
                        "nativeName": "English"
                    }
                ]
            }
        ]
        """.data(using: .utf8)
        
        let result = parser.parser(json)
        
        switch result {
        case .success(let countries):
            XCTAssertNotNil(countries)
            XCTAssertEqual(countries?.count, 1)
            XCTAssertEqual(countries?.first?.name, "Test Country")
        case .failure:
            XCTFail("Parser should succeed with valid JSON")
        }
    }
    
    func testParserFailure() {
        let parser = CountriesParser()
        
        // Create an invalid JSON
        let invalidJson = "Invalid JSON".data(using: .utf8)
        
        let result = parser.parser(invalidJson)
        
        switch result {
        case .success:
            XCTFail("Parser should fail with invalid JSON")
        case .failure(let error):
            XCTAssertEqual(error as? CountriesParserError, CountriesParserError.decodingFailure)
        }
    }
    
    func testParserWithNilData() {
        let parser = CountriesParser()
        
        let result = parser.parser(nil)
        
        switch result {
        case .success(let countries):
            XCTAssertNil(countries)
        case .failure:
            XCTFail("Parser should handle nil data")
        }
    }
    
    // MARK: - ViewModel Tests
    
    func testCountriesViewModel() {
        let viewModel = CountriesViewModel()
        
        // Test initial state
        XCTAssertTrue(viewModel.countriesSubject.value.isEmpty)
        XCTAssertNil(viewModel.errorSubject.value)
        
        // Create test country
        let country = Country(name: "Test Country", alpha2Code: "TC", alpha3Code: "TCY", capital: "Capital", region: "Region", population: 1000, currencies: [Currency(code: "USD", name: "Dollar", symbol: "$")], languages: [Language(name: "English", nativeName: "English")])
        
        // Manually set countries to test the subject
        viewModel.countriesSubject.value = [country]
        
        XCTAssertEqual(viewModel.countriesSubject.value.count, 1)
        XCTAssertEqual(viewModel.countriesSubject.value.first?.name, "Test Country")
    }
    
    func testCountriesViewModelRefresh() {
        // Create a custom view model with a mock service for testing
        class TestViewModel: CountriesViewModel {
            override func refreshCountries() {
                // Simulate successful fetch
                let country = Country(name: "Test Country", alpha2Code: "TC", alpha3Code: "TCY", capital: "Capital", region: "Region", population: 1000, currencies: [Currency(code: "USD", name: "Dollar", symbol: "$")], languages: [Language(name: "English", nativeName: "English")])
                self.countriesSubject.value = [country]
            }
        }
        
        let viewModel = TestViewModel()
        
        // Test initial state
        XCTAssertTrue(viewModel.countriesSubject.value.isEmpty)
        
        // Call refresh
        viewModel.refreshCountries()
        
        // Verify results
        XCTAssertEqual(viewModel.countriesSubject.value.count, 1)
        XCTAssertEqual(viewModel.countriesSubject.value.first?.name, "Test Country")
    }
    
    func testCountriesViewModelError() {
        // Create a custom view model with a mock service for testing
        class TestErrorViewModel: CountriesViewModel {
            override func refreshCountries() {
                // Simulate fetch error
                self.errorSubject.value = NSError(domain: "TestError", code: 1, userInfo: nil)
            }
        }
        
        let viewModel = TestErrorViewModel()
        
        // Test initial state
        XCTAssertNil(viewModel.errorSubject.value)
        
        // Call refresh
        viewModel.refreshCountries()
        
        // Verify error is set
        XCTAssertNotNil(viewModel.errorSubject.value)
        XCTAssertEqual((viewModel.errorSubject.value as NSError?)?.domain, "TestError")
    }

    func testCountriesViewModelWithMockService() {
        // Create a mock service
        class MockCountriesService: CountriesService {
            let mockCountries: [Country]
            
            init(mockCountries: [Country]) {
                self.mockCountries = mockCountries
                super.init()
            }
            
            override func fetchCountries() async throws -> [Country] {
                return mockCountries
            }
        }
        
        // Create test country
        let country = Country(name: "Test Country", alpha2Code: "TC", alpha3Code: "TCY", capital: "Capital", region: "Region", population: 1000, currencies: [Currency(code: "USD", name: "Dollar", symbol: "$")], languages: [Language(name: "English", nativeName: "English")])
        
        // Create mock service with test country
        let mockService = MockCountriesService(mockCountries: [country])
        
        // Create view model with mock service
        let viewModel = CountriesViewModel(service: mockService)
        
        // Test initial state
        XCTAssertTrue(viewModel.countriesSubject.value.isEmpty)
        
        // Call refresh
        viewModel.refreshCountries()
        
        // Need to wait for async task to complete
        let expectation = XCTestExpectation(description: "Wait for countries to load")
        
        // Check after a delay to allow for async completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Verify results
            XCTAssertEqual(viewModel.countriesSubject.value.count, 1)
            XCTAssertEqual(viewModel.countriesSubject.value.first?.name, "Test Country")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCountriesViewModelWithErrorService() {
        // Create a mock service that throws an error
        class ErrorCountriesService: CountriesService {
            override func fetchCountries() async throws -> [Country] {
                throw NSError(domain: "MockError", code: 1, userInfo: nil)
            }
        }
        
        // Create view model with error service
        let viewModel = CountriesViewModel(service: ErrorCountriesService())
        
        // Test initial state
        XCTAssertNil(viewModel.errorSubject.value)
        
        // Call refresh
        viewModel.refreshCountries()
        
        // Need to wait for async task to complete
        let expectation = XCTestExpectation(description: "Wait for error to be set")
        
        // Check after a delay to allow for async completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Verify error is set
            XCTAssertNotNil(viewModel.errorSubject.value)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Network Tests
    
    func testCountriesServiceSuccess() {
        // Create a mock URLSession for testing
        let mockSession = MockURLSession()
        let service = CountriesService()
        
        // Replace the URLSession with our mock
        service.session = mockSession as URLSession
        
        // Create sample data
        let sampleData = """
        [
            {
                "name": "Test Country",
                "alpha2Code": "TC",
                "alpha3Code": "TCY",
                "capital": "Capital",
                "region": "Region",
                "population": 1000,
                "currencies": [
                    {
                        "code": "USD",
                        "name": "Dollar",
                        "symbol": "$"
                    }
                ],
                "languages": [
                    {
                        "name": "English",
                        "nativeName": "English"
                    }
                ]
            }
        ]
        """.data(using: .utf8)
        
        // Setup the mock to return success
        mockSession.data = sampleData
        mockSession.error = nil
        
        // Create an expectation
        let expectation = self.expectation(description: "Service should return countries")
        
        // Call the service
        service.fetchCountries { result in
            switch result {
            case .success(let countries):
                XCTAssertNotNil(countries)
                XCTAssertEqual(countries?.count, 1)
                XCTAssertEqual(countries?.first?.name, "Test Country")
            case .failure:
                XCTFail("Service should succeed with valid data")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCountriesServiceFailure() {
        // Create a mock URLSession for testing
        let mockSession = MockURLSession()
        let service = CountriesService()
        
        // Replace the URLSession with our mock
        service.session = mockSession as URLSession
        
        // Setup the mock to return an error
        mockSession.data = nil
        mockSession.error = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        // Create an expectation
        let expectation = self.expectation(description: "Service should return error")
        
        // Call the service
        service.fetchCountries { result in
            switch result {
            case .success:
                XCTFail("Service should fail with error")
            case .failure:
                // Success - we got an error as expected
                break
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    // MARK: - View Controller Tests
    
    func testCountriesViewController() {
        let viewController = CountriesViewController()
        
        // Load view
        XCTAssertNotNil(viewController.view)
        
        // Check table view exists
        XCTAssertNotNil(viewController.tableView)
        
        // Test that setting countries updates the view model
        let country = Country(name: "Test Country", alpha2Code: "TC", alpha3Code: "TCY", capital: "Capital", region: "Region", population: 1000, currencies: [Currency(code: "USD", name: "Dollar", symbol: "$")], languages: [Language(name: "English", nativeName: "English")])
        
        viewController.viewModel.countries = [country]
        XCTAssertEqual(viewController.viewModel.countries.count, 1)
        
        // Test table view data source methods
        let numberOfSections = viewController.numberOfSections(in: viewController.tableView)
        XCTAssertEqual(numberOfSections, 1)
        
        let numberOfRows = viewController.tableView(viewController.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(numberOfRows, 1)
        
        // Test search functionality
        viewController.searchController.searchBar.text = "Test"
        // Manually trigger search
        viewController.updateSearchResults(for: viewController.searchController)
        
        // Test Detail view controller creation
        let detailVC = viewController.createDetailViewController(for: country)
        XCTAssertNotNil(detailVC)
        XCTAssertEqual(detailVC.country.name, "Test Country")
    }
    
    func testCountryDetailViewController() {
        let country = Country(name: "Test Country", alpha2Code: "TC", alpha3Code: "TCY", capital: "Capital", region: "Region", population: 1000, currencies: [Currency(code: "USD", name: "Dollar", symbol: "$")], languages: [Language(name: "English", nativeName: "English")])
        
        let viewController = CountryDetailViewController(country: country)
        
        // Load view
        XCTAssertNotNil(viewController.view)
        
        // Check country is set correctly
        XCTAssertEqual(viewController.country.name, "Test Country")
        
        // Check scrollView exists
        XCTAssertNotNil(viewController.scrollView)
        
        // Check labels are set correctly
        XCTAssertEqual(viewController.nameLabel.text, "Test Country")
        XCTAssertEqual(viewController.codeLabel.text, "TC (TCY)")
        XCTAssertEqual(viewController.capitalLabel.text, "Capital")
        XCTAssertEqual(viewController.regionLabel.text, "Region")
        XCTAssertEqual(viewController.populationLabel.text, "1,000")
    }
    
    // MARK: - View Tests
    
    func testCountryCell() {
        let country = Country(name: "Test Country", alpha2Code: "TC", alpha3Code: "TCY", capital: "Capital", region: "Region", population: 1000, currencies: [Currency(code: "USD", name: "Dollar", symbol: "$")], languages: [Language(name: "English", nativeName: "English")])
        
        let cell = CountryCell()
        
        // Configure cell
        cell.configure(with: country)
        
        // Check labels are set correctly
        XCTAssertEqual(cell.nameLabel.text, "Test Country")
        XCTAssertEqual(cell.codeLabel.text, "TC")
        XCTAssertEqual(cell.capitalLabel.text, "Capital")
    }
}

// Mock URLSession for testing network code
class MockURLSession: URLSession {
    var data: Data?
    var error: Error?
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        completionHandler(data, response, error)
        return MockURLSessionDataTask()
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    override func resume() {
        // Do nothing
    }
}
