from django.db import models

# String-based choices (matching registration model)
BLOOD_GROUP_CHOICES = [
    ("A+", "A+"),
    ("A-", "A-"),
    ("B+", "B+"),
    ("B-", "B-"),
    ("AB+", "AB+"),
    ("AB-", "AB-"),
    ("O+", "O+"),
    ("O-", "O-"),
]

GENDER_CHOICES = [
    ("Male", "Male"),
    ("Female", "Female"),
    ("Other", "Other"),
]

PROVINCE_CHOICES = [
    ("Punjab", "Punjab"),
    ("Sindh", "Sindh"),
    ("Khyber Pakhtunkhwa", "Khyber Pakhtunkhwa"),
    ("Balochistan", "Balochistan"),
    ("Islamabad Capital Territory", "Islamabad Capital Territory"),
    ("Gilgit-Baltistan", "Gilgit-Baltistan"),
    ("Azad Jammu and Kashmir", "Azad Jammu and Kashmir"),
]

DISTRICT_CHOICES = [
    # Punjab
    ("Ahmedpur East", "Ahmedpur East"),
    ("Arifwala", "Arifwala"),
    ("Attock", "Attock"),
    ("Bahawalnagar", "Bahawalnagar"),
    ("Bahawalpur", "Bahawalpur"),
    ("Bhakkar", "Bhakkar"),
    ("Burewala", "Burewala"),
    ("Chakwal", "Chakwal"),
    ("Chiniot", "Chiniot"),
    ("Dera Ghazi Khan", "Dera Ghazi Khan"),
    ("Faisalabad", "Faisalabad"),
    ("Ferozewala", "Ferozewala"),
    ("Gujranwala", "Gujranwala"),
    ("Gujrat", "Gujrat"),
    ("Hafizabad", "Hafizabad"),
    ("Jhang", "Jhang"),
    ("Jhelum", "Jhelum"),
    ("Kasur", "Kasur"),
    ("Khanewal", "Khanewal"),
    ("Khushab", "Khushab"),
    ("Lahore", "Lahore"),
    ("Layyah", "Layyah"),
    ("Lodhran", "Lodhran"),
    ("Mandi Bahauddin", "Mandi Bahauddin"),
    ("Mianwali", "Mianwali"),
    ("Multan", "Multan"),
    ("Muzaffargarh", "Muzaffargarh"),
    ("Nankana Sahib", "Nankana Sahib"),
    ("Narowal", "Narowal"),
    ("Okara", "Okara"),
    ("Pakpattan", "Pakpattan"),
    ("Rahim Yar Khan", "Rahim Yar Khan"),
    ("Rajanpur", "Rajanpur"),
    ("Rawalpindi", "Rawalpindi"),
    ("Sahiwal", "Sahiwal"),
    ("Sargodha", "Sargodha"),
    ("Sheikhupura", "Sheikhupura"),
    ("Sialkot", "Sialkot"),
    ("Toba Tek Singh", "Toba Tek Singh"),
    ("Vehari", "Vehari"),
    ("Wazirabad", "Wazirabad"),
    # Sindh
    ("Badin", "Badin"),
    ("Bhan", "Bhan"),
    ("Chachro", "Chachro"),
    ("Dadu", "Dadu"),
    ("Diplo", "Diplo"),
    ("Ghotki", "Ghotki"),
    ("Hyderabad", "Hyderabad"),
    ("Jacobabad", "Jacobabad"),
    ("Jamshoro", "Jamshoro"),
    ("Karachi", "Karachi"),
    ("Kashmore", "Kashmore"),
    ("Kandhkot", "Kandhkot"),
    ("Khairpur", "Khairpur"),
    ("Kotri", "Kotri"),
    ("Larkana", "Larkana"),
    ("Matiari", "Matiari"),
    ("Mirpur Khas", "Mirpur Khas"),
    ("Mithi", "Mithi"),
    ("Nawabshah", "Nawabshah"),
    ("Naushehro Feroze", "Naushehro Feroze"),
    ("Qambar", "Qambar"),
    ("Sanghar", "Sanghar"),
    ("Shahdadkot", "Shahdadkot"),
    ("Shikarpur", "Shikarpur"),
    ("Sukkur", "Sukkur"),
    ("Tando Adam", "Tando Adam"),
    ("Tando Allahyar", "Tando Allahyar"),
    ("Thatta", "Thatta"),
    ("Umerkot", "Umerkot"),
    # Khyber Pakhtunkhwa
    ("Abbottabad", "Abbottabad"),
    ("Bannu", "Bannu"),
    ("Batagram", "Batagram"),
    ("Buner", "Buner"),
    ("Charsadda", "Charsadda"),
    ("Chitral", "Chitral"),
    ("Dera Ismail Khan", "Dera Ismail Khan"),
    ("Dir", "Dir"),
    ("Haripur", "Haripur"),
    ("Karak", "Karak"),
    ("Kohat", "Kohat"),
    ("Kohistan", "Kohistan"),
    ("Lakki Marwat", "Lakki Marwat"),
    ("Lower Dir", "Lower Dir"),
    ("Malakand", "Malakand"),
    ("Mansehra", "Mansehra"),
    ("Mardan", "Mardan"),
    ("Nowshera", "Nowshera"),
    ("Peshawar", "Peshawar"),
    ("Shangla", "Shangla"),
    ("Swabi", "Swabi"),
    ("Swat", "Swat"),
    ("Tank", "Tank"),
    ("Upper Dir", "Upper Dir"),
    # Balochistan
    ("Awaran", "Awaran"),
    ("Barkhan", "Barkhan"),
    ("Bolan", "Bolan"),
    ("Chagai", "Chagai"),
    ("Dera Bugti", "Dera Bugti"),
    ("Gwadar", "Gwadar"),
    ("Harnai", "Harnai"),
    ("Jafarabad", "Jafarabad"),
    ("Jhal Magsi", "Jhal Magsi"),
    ("Kalat", "Kalat"),
    ("Kech", "Kech"),
    ("Kharan", "Kharan"),
    ("Khuzdar", "Khuzdar"),
    ("Killa Abdullah", "Killa Abdullah"),
    ("Killa Saifullah", "Killa Saifullah"),
    ("Kohlu", "Kohlu"),
    ("Lasbela", "Lasbela"),
    ("Loralai", "Loralai"),
    ("Mastung", "Mastung"),
    ("Musakhel", "Musakhel"),
    ("Nasirabad", "Nasirabad"),
    ("Nushki", "Nushki"),
    ("Panjgur", "Panjgur"),
    ("Pishin", "Pishin"),
    ("Quetta", "Quetta"),
    ("Sherani", "Sherani"),
    ("Sibi", "Sibi"),
    ("Sohbatpur", "Sohbatpur"),
    ("Washuk", "Washuk"),
    ("Zhob", "Zhob"),
    ("Ziarat", "Ziarat"),
    # Islamabad Capital Territory
    ("Islamabad", "Islamabad"),
    # Gilgit-Baltistan
    ("Astore", "Astore"),
    ("Ghizer", "Ghizer"),
    ("Ghanche", "Ghanche"),
    ("Gilgit", "Gilgit"),
    ("Hunza", "Hunza"),
    ("Nagar", "Nagar"),
    ("Skardu", "Skardu"),
    ("Shigar", "Shigar"),
    ("Kharmang", "Kharmang"),
    ("Roundu", "Roundu"),
    # Azad Jammu and Kashmir
    ("Bagh", "Bagh"),
    ("Bhimber", "Bhimber"),
    ("Hattian", "Hattian"),
    ("Haveli", "Haveli"),
    ("Kotli", "Kotli"),
    ("Mirpur", "Mirpur"),
    ("Muzaffarabad", "Muzaffarabad"),
    ("Neelum", "Neelum"),
    ("Poonch", "Poonch"),
    ("Rawalakot", "Rawalakot"),
    ("Sudhanoti", "Sudhanoti"),
]

REQUEST_STATUS = [
    ("pending", "Pending"),
    ("accepted", "Accepted"),
    ("partially_fulfilled", "Partially Fulfilled"),
    ("completed", "Completed"),
    ("cancelled", "Cancelled"),
]


class BloodRequest(models.Model):
    id = models.AutoField(primary_key=True)
    user_id = models.IntegerField()
    patient_name = models.CharField(max_length=100)
    emergency_contact = models.CharField(max_length=15)
    blood_group = models.CharField(max_length=5, choices=BLOOD_GROUP_CHOICES, default="A+")  # String-based blood group
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, default="Male")  # String-based gender
    province = models.CharField(max_length=50, choices=PROVINCE_CHOICES, default="Punjab")  # String-based province
    district = models.CharField(max_length=100, choices=DISTRICT_CHOICES, blank=True, null=True)  # String-based district
    local_level = models.CharField(max_length=200, blank=True, null=True)
    units_required = models.IntegerField()
    required_date = models.DateField(blank=True, null=True)
    required_time = models.TimeField(blank=True, null=True)
    case = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=30, choices=REQUEST_STATUS, default="pending")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.patient_name} - {self.blood_group} ({self.status})"

    @property
    def blood_group_name(self):
        """Get blood group display name"""
        return dict(BLOOD_GROUP_CHOICES).get(self.blood_group, self.blood_group)

    @property
    def gender_name(self):
        """Get gender display name"""
        return dict(GENDER_CHOICES).get(self.gender, self.gender)

    @property
    def province_name(self):
        """Get province display name"""
        return dict(PROVINCE_CHOICES).get(self.province, self.province)

    @property
    def district_name(self):
        """Get district display name"""
        return dict(DISTRICT_CHOICES).get(self.district, self.district)
