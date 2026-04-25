import '../models/donor_model.dart';
import '../utils/mock_data.dart';

class DonorService {
  // Replace with actual API endpoint when backend is ready
  static const String baseUrl = 'http://your-backend-api.com';

  // Fetch donors from API (future implementation)
  static Future<List<Donor>> fetchDonors({
    String? bloodGroup,
    String? province,
    String? district,
    String? searchQuery,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // For now, return mock data
    return MockDonorData.getMockDonors();
  }

  // Filter donors locally
  static List<Donor> filterDonors(
    List<Donor> donors, {
    String? bloodGroup,
    String? province,
    String? district,
    String? searchQuery,
  }) {
    List<Donor> filtered = List.from(donors);

    // Filter by blood group
    if (bloodGroup != null && bloodGroup.isNotEmpty) {
      filtered = filtered.where((d) => d.bloodGroup == bloodGroup).toList();
    }

    // Filter by province
    if (province != null && province.isNotEmpty) {
      filtered = filtered.where((d) => d.province == province).toList();
    }

    // Filter by district
    if (district != null && district.isNotEmpty) {
      filtered = filtered.where((d) => d.district == district).toList();
    }

    // Filter by search query (name, district, local level)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((d) {
        final query = searchQuery.toLowerCase();
        return d.name.toLowerCase().contains(query) ||
            d.district.toLowerCase().contains(query) ||
            d.localLevel.toLowerCase().contains(query) ||
            d.bloodGroup.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  // Sort donors by different criteria
  static List<Donor> sortDonors(List<Donor> donors, String sortBy) {
    List<Donor> sorted = List.from(donors);

    switch (sortBy) {
      case 'distance':
        sorted.sort((a, b) {
          if (a.distance == null && b.distance == null) return 0;
          if (a.distance == null) return 1;
          if (b.distance == null) return -1;
          return a.distance!.compareTo(b.distance!);
        });
        break;
      case 'lastDonation':
        sorted.sort((a, b) => a.lastDonationDate.compareTo(b.lastDonationDate));
        break;
      case 'name':
        sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'totalDonations':
        sorted.sort((a, b) => b.totalDonations.compareTo(a.totalDonations));
        break;
      default:
        break;
    }

    return sorted;
  }
}
