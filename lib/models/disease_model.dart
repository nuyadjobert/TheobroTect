class Disease {
  final String image;
  final List<String> images;
  final String title;
  final String origin;
  final String description;
  final List<String> symptoms;
  final Map<String, String> tagalog;

  Disease({
    required this.image,
    required this.images,
    required this.title,
    required this.origin,
    required this.description,
    required this.symptoms,
    required this.tagalog,
  });

  static List<Disease> get cacaoDiseases => [
        Disease(
          image: "assets/images/pb_bg.png",
          images: ["assets/images/pb1.png", "assets/images/pb2.png", "assets/images/pb3.png"],
          title: "Cacao Pod Borer",
          origin: "Southeast Asia",
          description: "A small moth whose larvae tunnel into cocoa pods, disrupting bean development.",
          symptoms: ["Premature ripening", "Uneven pod coloring", "Small exit holes", "Clumped, damaged beans"],
          tagalog: {
            "description": "Isang maliit na gamu-gamo kung saan ang mga uod nito ay bumubutas sa loob ng bunga ng kakaw...",
            "symptoms": "Maagang pagkahinog ng bunga, Hindi pantay na kulay ng balat...",
          },
        ),
        Disease(
          image: "assets/images/bp_bg.png",
          images: ["assets/images/bp1.png", "assets/images/bp2.png", "assets/images/bp3.png"],
          title: "Black Pod Rot",
          origin: "Worldwide (Tropical)",
          description: "Caused by Phytophthora fungi, it spreads rapidly in wet conditions.",
          symptoms: ["Expanding dark brown spots", "White fungal growth", "Firm rot on pod surface", "Rotted internal beans"],
          tagalog: {
            "description": "Sanhi ng halamang-singaw na Phytophthora, mabilis itong kumakalat...",
            "symptoms": "Lumalawak na maitim o kulay-kape na mga batik...",
          },
        ),
        Disease(
          image: "assets/images/mb_bg.png",
          images: ["assets/images/mb1.png", "assets/images/mb2.png", "assets/images/mb3.png"],
          title: "Mealybugs",
          origin: "Global Tropics",
          description: "Soft-bodied insects that suck sap and secrete honeydew, often spreading viruses.",
          symptoms: ["White cottony clusters", "Sticky honeydew on leaves", "Sooty mold growth", "Yellowing of foliage"],
          tagalog: {
            "description": "Malambot na insekto na sumisipsip ng dagta ng puno at naglalabas ng malagkit na likido...",
            "symptoms": "Mapuputi at parang bulak na kumpol...",
          },
        ),
      ];
}