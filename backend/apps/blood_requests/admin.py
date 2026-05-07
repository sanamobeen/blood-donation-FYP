from django.contrib import admin
from django import forms
from .models import BloodRequest

# District choices for admin dropdown (string-based like registration)
DISTRICT_CHOICES = [
    # Punjab
    ("Ahmedpur East", "Ahmedpur East"), ("Arifwala", "Arifwala"), ("Attock", "Attock"), ("Bahawalnagar", "Bahawalnagar"),
    ("Bahawalpur", "Bahawalpur"), ("Bhakkar", "Bhakkar"), ("Burewala", "Burewala"), ("Chakwal", "Chakwal"),
    ("Chiniot", "Chiniot"), ("Dera Ghazi Khan", "Dera Ghazi Khan"), ("Faisalabad", "Faisalabad"), ("Ferozewala", "Ferozewala"),
    ("Gujranwala", "Gujranwala"), ("Gujrat", "Gujrat"), ("Hafizabad", "Hafizabad"), ("Jhang", "Jhang"),
    ("Jhelum", "Jhelum"), ("Kasur", "Kasur"), ("Khanewal", "Khanewal"), ("Khushab", "Khushab"),
    ("Lahore", "Lahore"), ("Layyah", "Layyah"), ("Lodhran", "Lodhran"), ("Mandi Bahauddin", "Mandi Bahauddin"),
    ("Mianwali", "Mianwali"), ("Multan", "Multan"), ("Muzaffargarh", "Muzaffargarh"), ("Nankana Sahib", "Nankana Sahib"),
    ("Narowal", "Narowal"), ("Okara", "Okara"), ("Pakpattan", "Pakpattan"), ("Rahim Yar Khan", "Rahim Yar Khan"),
    ("Rajanpur", "Rajanpur"), ("Rawalpindi", "Rawalpindi"), ("Sahiwal", "Sahiwal"), ("Sargodha", "Sargodha"),
    ("Sheikhupura", "Sheikhupura"), ("Sialkot", "Sialkot"), ("Toba Tek Singh", "Toba Tek Singh"),
    ("Vehari", "Vehari"), ("Wazirabad", "Wazirabad"),
    # Sindh
    ("Badin", "Badin"), ("Bhan", "Bhan"), ("Chachro", "Chachro"), ("Dadu", "Dadu"),
    ("Diplo", "Diplo"), ("Ghotki", "Ghotki"), ("Hyderabad", "Hyderabad"), ("Jacobabad", "Jacobabad"),
    ("Jamshoro", "Jamshoro"), ("Karachi", "Karachi"), ("Kashmore", "Kashmore"), ("Kandhkot", "Kandhkot"),
    ("Khairpur", "Khairpur"), ("Kotri", "Kotri"), ("Larkana", "Larkana"), ("Matiari", "Matiari"),
    ("Mirpur Khas", "Mirpur Khas"), ("Mithi", "Mithi"), ("Nawabshah", "Nawabshah"), ("Naushehro Feroze", "Naushehro Feroze"),
    ("Qambar", "Qambar"), ("Sanghar", "Sanghar"), ("Shahdadkot", "Shahdadkot"), ("Shikarpur", "Shikarpur"),
    ("Sukkur", "Sukkur"), ("Tando Adam", "Tando Adam"), ("Tando Allahyar", "Tando Allahyar"),
    ("Thatta", "Thatta"), ("Umerkot", "Umerkot"),
    # KPK
    ("Abbottabad", "Abbottabad"), ("Bannu", "Bannu"), ("Batagram", "Batagram"), ("Buner", "Buner"),
    ("Charsadda", "Charsadda"), ("Chitral", "Chitral"), ("Dera Ismail Khan", "Dera Ismail Khan"), ("Dir", "Dir"),
    ("Haripur", "Haripur"), ("Karak", "Karak"), ("Kohat", "Kohat"), ("Kohistan", "Kohistan"),
    ("Lakki Marwat", "Lakki Marwat"), ("Lower Dir", "Lower Dir"), ("Malakand", "Malakand"),
    ("Mansehra", "Mansehra"), ("Mardan", "Mardan"), ("Nowshera", "Nowshera"), ("Peshawar", "Peshawar"),
    ("Shangla", "Shangla"), ("Swabi", "Swabi"), ("Swat", "Swat"), ("Tank", "Tank"),
    ("Upper Dir", "Upper Dir"),
    # Balochistan
    ("Awaran", "Awaran"), ("Barkhan", "Barkhan"), ("Bolan", "Bolan"), ("Chagai", "Chagai"),
    ("Dera Bugti", "Dera Bugti"), ("Gwadar", "Gwadar"), ("Harnai", "Harnai"), ("Jafarabad", "Jafarabad"),
    ("Jhal Magsi", "Jhal Magsi"), ("Kalat", "Kalat"), ("Kech", "Kech"), ("Kharan", "Kharan"),
    ("Khuzdar", "Khuzdar"), ("Killa Abdullah", "Killa Abdullah"), ("Killa Saifullah", "Killa Saifullah"),
    ("Kohlu", "Kohlu"), ("Lasbela", "Lasbela"), ("Loralai", "Loralai"), ("Mastung", "Mastung"),
    ("Musakhel", "Musakhel"), ("Nasirabad", "Nasirabad"), ("Nushki", "Nushki"), ("Panjgur", "Panjgur"),
    ("Pishin", "Pishin"), ("Quetta", "Quetta"), ("Sherani", "Sherani"), ("Sibi", "Sibi"),
    ("Sohbatpur", "Sohbatpur"), ("Washuk", "Washuk"), ("Zhob", "Zhob"), ("Ziarat", "Ziarat"),
    # Islamabad
    ("Islamabad", "Islamabad"),
    # Gilgit-Baltistan
    ("Astore", "Astore"), ("Ghizer", "Ghizer"), ("Ghanche", "Ghanche"), ("Gilgit", "Gilgit"),
    ("Hunza", "Hunza"), ("Nagar", "Nagar"), ("Skardu", "Skardu"), ("Shigar", "Shigar"),
    ("Kharmang", "Kharmang"), ("Roundu", "Roundu"),
    # Azad Kashmir
    ("Bagh", "Bagh"), ("Bhimber", "Bhimber"), ("Hattian", "Hattian"), ("Haveli", "Haveli"),
    ("Kotli", "Kotli"), ("Mirpur", "Mirpur"), ("Muzaffarabad", "Muzaffarabad"), ("Neelum", "Neelum"),
    ("Poonch", "Poonch"), ("Rawalakot", "Rawalakot"), ("Sudhanoti", "Sudhanoti"),
]


class BloodRequestAdminForm(forms.ModelForm):
    """Custom form to make district a dropdown in admin"""

    district = forms.ChoiceField(
        choices=[('', '---------')] + list(DISTRICT_CHOICES),
        required=False,
        help_text="Select district from dropdown"
    )

    class Meta:
        model = BloodRequest
        fields = '__all__'


@admin.register(BloodRequest)
class BloodRequestAdmin(admin.ModelAdmin):
    form = BloodRequestAdminForm
    list_display = [
        "patient_name",
        "blood_group",
        "province",
        "district",
        "units_required",
        "status",
        "required_date",
        "created_at",
    ]
    list_filter = ["status", "blood_group", "province", "gender", "created_at"]
    search_fields = ["patient_name", "district", "case"]
    readonly_fields = ["created_at", "updated_at"]
    ordering = ["-created_at"]

    fieldsets = (
        ("Patient Information", {
            "fields": ("patient_name", "emergency_contact", "gender")
        }),
        ("Blood Requirements", {
            "fields": ("blood_group", "units_required", "case")
        }),
        ("Location", {
            "fields": ("province", "district", "local_level")
        }),
        ("Schedule", {
            "fields": ("required_date", "required_time")
        }),
        ("Status & Metadata", {
            "fields": ("status", "created_at", "updated_at")
        }),
    )
