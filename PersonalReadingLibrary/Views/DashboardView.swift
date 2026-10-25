import SwiftUI

struct DashboardView: View {
    @State private var viewModel: DashboardViewModel

    init(persistenceService: PersistenceService) {
        _viewModel = State(
            initialValue: DashboardViewModel(
                persistenceService: persistenceService
            )
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if !viewModel.errorMessage.isEmpty {
                    ContentUnavailableView(
                        "Unable to Load Dashboard",
                        systemImage: "exclamationmark.triangle",
                        description: Text(viewModel.errorMessage)
                    )
                } else {
                    List {
                        Section("Reading Summary") {
                            HStack {
                                Label(
                                    "Total Books",
                                    systemImage: "books.vertical.fill"
                                )

                                Spacer()

                                Text("\(viewModel.totalBooks)")
                                    .fontWeight(.bold)
                            }

                            HStack {
                                Label(
                                    "Completed",
                                    systemImage: "checkmark.circle.fill"
                                )
                                .foregroundStyle(.green)

                                Spacer()

                                Text("\(viewModel.completedBooks)")
                                    .fontWeight(.bold)
                            }

                            HStack {
                                Label(
                                    "Currently Reading",
                                    systemImage: "book.fill"
                                )
                                .foregroundStyle(.blue)

                                Spacer()

                                Text("\(viewModel.readingBooks)")
                                    .fontWeight(.bold)
                            }
                        }

                        if viewModel.totalBooks == 0 {
                            Section {
                                Text("Add books to start tracking your reading.")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .onAppear {
                viewModel.loadDashboard()
            }
        }
    }
}

