import SwiftUI

struct LocationSelectionView: View {
    @ObservedObject private var viewModel: LocationSelectionViewModel

    init(viewModel: LocationSelectionViewModel) {
        self.viewModel = viewModel

        customize()
    }

    var subscribedNodes: some View {
        VStack {
            if !viewModel.isLoadingSubscriptions && viewModel.subscriptions.isEmpty {
                Spacer()

                Text(L10n.LocationSelection.Node.Subscribed.notFound)
                    .font(.system(size: 25, weight: .medium))
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)

                Image(uiImage: Asset.LocationSelector.empty.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 250)

                Spacer()
            } else {
                List {
                    ForEach(viewModel.subscriptions, id: \.self) { vm in
                        LocationSelectionRowView(
                            viewModel: vm,
                            toggleLocation: {
                                viewModel.toggleLocation(with: vm.id)
                            },
                            openDetails: {
                                viewModel.openDetails(for:  vm.id)
                            }
                        )
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
                .listRowBackground(Color.green)
            }

            ActivityIndicator(
                isAnimating: $viewModel.isLoadingSubscriptions,
                style: .medium
            )
        }
    }

    var availableNodes: some View {
        VStack {
            if viewModel.isAllLoaded && viewModel.locations.isEmpty {
                Spacer()

                Text(L10n.LocationSelection.Node.All.notFound)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)

                Spacer()
            } else {
                List {
                    ForEach(Array(zip(viewModel.locations.indices, viewModel.locations)), id: \.0) { index, vm in
                        LocationSelectionRowView(
                            viewModel: vm,
                            toggleLocation: {
                                viewModel.toggleLocation(with: vm.id)
                            },
                            openDetails: {
                                viewModel.openDetails(for:  vm.id)
                            }
                        )
                            .onAppear {
                                if index == viewModel.locations.count - 1, !viewModel.isLoadingNodes, !viewModel.isAllLoaded {
                                    viewModel.loadNodes()
                                }
                            }
                            .listRowBackground(Color.clear)

                    }
                }
                .listStyle(PlainListStyle())
                .listRowBackground(Color.green)
            }

            ActivityIndicator(
                isAnimating: $viewModel.isLoadingNodes,
                style: .medium
            )
        }
    }

    var locationSelector: some View {
        VStack {
            HStack {
                switch(viewModel.selectedTab) {
                case .subscribed:
                    subscribedNodes
                case .available:
                    availableNodes
                }
            }

            ZStack {
                Picker("", selection: $viewModel.selectedTab) {
                    ForEach(NodeType.allCases, id: \.self) {
                        Text($0.title)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Button(action: viewModel.toggleRandomLocation) {
                    Image(systemName: "power")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
                .frame(width: 60, height: 60)
                .background(viewModel.connectionStatus.powerColor)
                .cornerRadius(30)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
            .padding(.top, 10)
        }
    }

    var extraView: some View {
        VStack {
            Spacer()
            Image(uiImage: Asset.LocationSelector.globe.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(L10n.LocationSelection.Extra.text)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .multilineTextAlignment(.center)

            Text(L10n.LocationSelection.Extra.subtitle)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Asset.Colors.Redesign.lightGray.color.asColor)
                .padding(.horizontal)
                .multilineTextAlignment(.center)

            Spacer()

            Button(action: viewModel.openMore) {
                HStack {
                    Spacer()
                    Text(L10n.LocationSelection.Extra.Button.more.uppercased())
                        .foregroundColor(Asset.Colors.Redesign.backgroundColor.color.asColor)
                        .font(.system(size: 13, weight: .semibold))

                    Spacer()
                }
            }
            .padding()
            .background(Asset.Colors.Redesign.navyBlue.color.asColor)
            .cornerRadius(25)
            .padding(.horizontal, 40)

            Spacer()


            HStack {
                HStack(spacing: 0) {
                    Text(L10n.LocationSelection.Extra.build)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Asset.Colors.Redesign.lightGray.color.asColor)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)

                    Image(uiImage: Asset.Icons.exidio.image)
                        .resizable()
                        .frame(width: 25, height: 25)

                    Text("EXIDIO")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .multilineTextAlignment(.center)
                }
                .padding()

                Spacer()


                Text("V\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1")")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Asset.Colors.Redesign.lightGray.color.asColor)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding(.bottom)
            .background(Asset.Colors.Redesign.prussianBlue.color.asColor)
        }
    }

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            extraView
                .rotationEffect(.degrees(-180))
                .tag(LocationSelectionViewModel.PageType.extra)
            
            locationSelector
                .rotationEffect(.degrees(-180))
                .tag(LocationSelectionViewModel.PageType.selector)
        }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .background(Asset.Colors.Redesign.backgroundColor.color.asColor)
            .rotationEffect(.degrees(-180))
            .edgesIgnoringSafeArea(.bottom)
            .onAppear(perform: viewModel.viewWillAppear)
    }
}

extension LocationSelectionView {
    private func customize() {
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear

        let controlAppearance = UISegmentedControl.appearance()

        controlAppearance.selectedSegmentTintColor = Asset.Colors.Redesign.backgroundColor.color
        controlAppearance.setTitleTextAttributes(
            [.foregroundColor: Asset.Colors.Redesign.navyBlue.color],
            for: .selected
        )
        controlAppearance.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .normal
        )
    }
}

struct LocationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getLocationSelectionScene()
    }
}
