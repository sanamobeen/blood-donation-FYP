import '../models/donor_model.dart';

class MockDonorData {
  static List<Donor> getMockDonors() {
    return [
      // Province 3 - Kathmandu Valley
      Donor(
        id: '1',
        name: 'Ram Bahadur',
        bloodGroup: 'A+',
        province: 'Province 3',
        district: 'Kathmandu',
        localLevel: 'Kathmandu Metropolitan City',
        phone: '+977-9841234567',
        email: 'ram.bahadur@example.com',
        lastDonationDate: DateTime(2024, 3, 15),
        totalDonations: 8,
        isAvailable: true,
        gender: 'Male',
        distance: 2.5,
        latitude: 27.7172,
        longitude: 85.3240,
      ),
      Donor(
        id: '2',
        name: 'Sita Sharma',
        bloodGroup: 'B+',
        province: 'Province 3',
        district: 'Lalitpur',
        localLevel: 'Lalitpur Metropolitan City',
        phone: '+977-9842345678',
        email: 'sita.sharma@example.com',
        lastDonationDate: DateTime(2024, 2, 20),
        totalDonations: 5,
        isAvailable: true,
        gender: 'Female',
        distance: 4.2,
        latitude: 27.6527,
        longitude: 85.3190,
      ),
      Donor(
        id: '3',
        name: 'Hari Krishna',
        bloodGroup: 'O+',
        province: 'Province 3',
        district: 'Bhaktapur',
        localLevel: 'Bhaktapur Metropolitan City',
        phone: '+977-9843456789',
        email: 'hari.krishna@example.com',
        lastDonationDate: DateTime(2024, 1, 10),
        totalDonations: 12,
        isAvailable: false,
        gender: 'Male',
        distance: 6.8,
        latitude: 27.6721,
        longitude: 85.4249,
      ),
      Donor(
        id: '11',
        name: 'Dipesh Shrestha',
        bloodGroup: 'A+',
        province: 'Province 3',
        district: 'Kathmandu',
        localLevel: 'Tokha',
        phone: '+977-9844567890',
        email: 'dipesh.shrestha@example.com',
        lastDonationDate: DateTime(2024, 3, 18),
        totalDonations: 2,
        isAvailable: true,
        gender: 'Male',
        distance: 3.2,
        latitude: 27.7272,
        longitude: 85.3420,
      ),
      Donor(
        id: '12',
        name: 'Sanjina Karki',
        bloodGroup: 'O+',
        province: 'Province 3',
        district: 'Kathmandu',
        localLevel: 'Kageshwori Manohara',
        phone: '+977-9845678901',
        email: 'sanjina.karki@example.com',
        lastDonationDate: DateTime(2023, 10, 15),
        totalDonations: 10,
        isAvailable: true,
        gender: 'Female',
        distance: 5.5,
        latitude: 27.6914,
        longitude: 85.3561,
      ),
      Donor(
        id: '14',
        name: 'Sushila KC',
        bloodGroup: 'A-',
        province: 'Province 3',
        district: 'Kathmandu',
        localLevel: 'Chandragiri',
        phone: '+977-9846789012',
        email: 'sushila.kc@example.com',
        lastDonationDate: DateTime(2024, 2, 10),
        totalDonations: 6,
        isAvailable: false,
        gender: 'Female',
        distance: 4.8,
        latitude: 27.7016,
        longitude: 85.2907,
      ),

      // Province 2
      Donor(
        id: '4',
        name: 'Gita Devi',
        bloodGroup: 'AB+',
        province: 'Province 2',
        district: 'Dhanusha',
        localLevel: 'Janakpur Sub-metropolitan City',
        phone: '+977-9851234567',
        email: 'gita.devi@example.com',
        lastDonationDate: DateTime(2023, 12, 5),
        totalDonations: 3,
        isAvailable: true,
        gender: 'Female',
        distance: 250.0,
        latitude: 26.7271,
        longitude: 85.9057,
      ),
      Donor(
        id: '5',
        name: 'Mukesh Yadav',
        bloodGroup: 'A-',
        province: 'Province 2',
        district: 'Parsa',
        localLevel: 'Birgunj Metropolitan City',
        phone: '+977-9852345678',
        email: 'mukesh.yadav@example.com',
        lastDonationDate: DateTime(2024, 3, 1),
        totalDonations: 7,
        isAvailable: true,
        gender: 'Male',
        distance: 220.0,
        latitude: 27.0167,
        longitude: 84.8803,
      ),
      Donor(
        id: '15',
        name: 'Nabin Pandey',
        bloodGroup: 'AB+',
        province: 'Province 2',
        district: 'Siraha',
        localLevel: 'Lahan',
        phone: '+977-9854567890',
        email: 'nabin.pandey@example.com',
        lastDonationDate: DateTime(2024, 3, 12),
        totalDonations: 3,
        isAvailable: true,
        gender: 'Male',
        distance: 240.0,
        latitude: 26.7322,
        longitude: 86.0667,
      ),

      // Province 1
      Donor(
        id: '6',
        name: 'Kumar Rai',
        bloodGroup: 'B-',
        province: 'Province 1',
        district: 'Morang',
        localLevel: 'Biratnagar Metropolitan City',
        phone: '+977-9811234567',
        email: 'kumar.rai@example.com',
        lastDonationDate: DateTime(2024, 2, 15),
        totalDonations: 4,
        isAvailable: true,
        gender: 'Male',
        distance: 400.0,
        latitude: 26.4525,
        longitude: 87.2718,
      ),
      Donor(
        id: '7',
        name: 'Priya Limbu',
        bloodGroup: 'O-',
        province: 'Province 1',
        district: 'Jhapa',
        localLevel: 'Mechinagar',
        phone: '+977-9812345678',
        email: 'priya.limbu@example.com',
        lastDonationDate: DateTime(2023, 11, 20),
        totalDonations: 9,
        isAvailable: true,
        gender: 'Female',
        distance: 450.0,
        latitude: 26.6252,
        longitude: 87.8873,
      ),

      // Province 4 (Gandaki)
      Donor(
        id: '8',
        name: 'Binod Tamang',
        bloodGroup: 'A+',
        province: 'Province 4',
        district: 'Kaski',
        localLevel: 'Pokhara Metropolitan City',
        phone: '+977-9821234567',
        email: 'binod.tamang@example.com',
        lastDonationDate: DateTime(2024, 3, 10),
        totalDonations: 6,
        isAvailable: true,
        gender: 'Male',
        distance: 180.0,
        latitude: 28.2096,
        longitude: 84.0124,
      ),
      Donor(
        id: '9',
        name: 'Anita Gurung',
        bloodGroup: 'B+',
        province: 'Province 4',
        district: 'Kaski',
        localLevel: 'Pokhara Metropolitan City',
        phone: '+977-9822345678',
        email: 'anita.gurung@example.com',
        lastDonationDate: DateTime(2024, 1, 25),
        totalDonations: 8,
        isAvailable: false,
        gender: 'Female',
        distance: 185.0,
        latitude: 28.2156,
        longitude: 84.0245,
      ),
      Donor(
        id: '13',
        name: 'Bikash Magar',
        bloodGroup: 'B+',
        province: 'Province 4',
        district: 'Syangja',
        localLevel: 'Waling',
        phone: '+977-9823456789',
        email: 'bikash.magar@example.com',
        lastDonationDate: DateTime(2024, 3, 5),
        totalDonations: 4,
        isAvailable: true,
        gender: 'Male',
        distance: 195.0,
        latitude: 28.0156,
        longitude: 83.8754,
      ),

      // Province 5 (Lumbini)
      Donor(
        id: '10',
        name: 'Ramesh Tharu',
        bloodGroup: 'AB-',
        province: 'Province 5',
        district: 'Rupandehi',
        localLevel: 'Butwal Sub-metropolitan City',
        phone: '+977-9853456789',
        email: 'ramesh.tharu@example.com',
        lastDonationDate: DateTime(2024, 2, 28),
        totalDonations: 5,
        isAvailable: true,
        gender: 'Male',
        distance: 280.0,
        latitude: 27.8128,
        longitude: 83.4359,
      ),
    ];
  }

  // Get all unique blood groups
  static List<String> getBloodGroups() {
    return ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  }

  // Get all unique provinces
  static List<String> getProvinces() {
    return [
      'Province 1',
      'Province 2',
      'Province 3',
      'Province 4',
      'Province 5',
    ];
  }

  // Get districts by province
  static List<String> getDistricts(String province) {
    switch (province) {
      case 'Province 1':
        return ['Morang', 'Jhapa', 'Sunsari', 'Ilam'];
      case 'Province 2':
        return ['Dhanusha', 'Parsa', 'Siraha', 'Bara'];
      case 'Province 3':
        return ['Kathmandu', 'Lalitpur', 'Bhaktapur', 'Nuwakot'];
      case 'Province 4':
        return ['Kaski', 'Syangja', 'Parbat', 'Lamjung'];
      case 'Province 5':
        return ['Rupandehi', 'Palpa', 'Gulmi', 'Arghakhanchi'];
      default:
        return [];
    }
  }
}
