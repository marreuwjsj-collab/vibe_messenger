class BusinessWorkspace { final String id; final String name; final String description; const BusinessWorkspace({required this.id, required this.name, required this.description}); }
class MarketplaceItem { final String id; final String title; final int price; const MarketplaceItem({required this.id, required this.title, required this.price}); }
abstract interface class BusinessRepository { Future<List<BusinessWorkspace>> workspaces(); Future<List<MarketplaceItem>> marketplace(); }
