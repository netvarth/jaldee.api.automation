from faker import Faker
from faker.providers import DynamicProvider

service_list = DynamicProvider(
     provider_name="services",
     elements= ["Digital marketing for community organizations", "Birth preparation classes", "Crowdsourced community feedback", "Healthy snack subscriptions", "Online program development for nonprofits", "Branding services", "Photography workshops", "Webinar hosting", "E-commerce analytics", "Business coaching", "Brand identity design", "Digital advocacy strategies for nonprofits", "Online focus groups", "Podcast advertising services", "Online fundraising campaigns for social causes", "Digital resource allocation for nonprofits", "Virtual fundraising events", "Educational consulting", "Virtual business audits", "E-commerce market research", "Real estate consulting", "Virtual social innovation workshops", "Virtual community planning", "Online lead nurturing", "Network setup and administration", "Virtual partnership building", "Corporate training", "Online community outreach for social initiatives", "Sustainable fashion consulting", "Facials", "Social media advertising", "Grant writing services", "Online community management", "Wellness retreats", "Remote community partnerships development", "Online marketing strategy development", "Cooking classes", "Digital storytelling consulting", "Firewood delivery", "Digital storytelling for social change", "Birdwatching tours", "Trade show planning", "Employee engagement programs", "Crowdsourcing community ideas", "Cooking classes for beginners", "Home staging", "Email list building strategies", "Employee engagement surveys", "Window cleaning", "Extracurricular activity organization", "Software development", "Payroll services", "Remote IT consulting", "Virtual grant writing workshops", "Content moderation", "Cybersecurity consulting", "Workplace conflict mediation", "Community organizing", "Social media management", "Fashion styling services", "Beauty product consulting", "Employee training programs", "Teen career coaching", "Virtual brainstorming sessions", "Translation services", "Online fundraising events for nonprofits", "Virtual health consultations", "Baking services", "Remote coalition management for social change", "Virtual volunteer training", "Digital storytelling for social initiatives", "Essential oils therapy", "Remote evaluation strategies", "Digital marketing automation consulting", "E-commerce consulting", "Social media audits", "Workplace wellness programs", "Executive coaching", "Tax preparation", "Crowdsourcing ideas", "Gourmet cooking classes", "Boat rentals", "Permanent makeup", "Fishing charter services", "Alteration services", "HVAC services", "Photography portfolio review", "Online privacy consulting", "Diversity and inclusion training", "Sales training programs", "Online engagement metrics analysis", "Home renovation services", "Insurance claims consulting", "Tech support for seniors", "Gamification in training", "Team coaching", "Dance classes", "Home appliance repair", "Virtual fact-checking services", "Remote stakeholder engagement", "Remote evaluation for community projects", "Test preparation", "Job fair organization", "Online program development for community impact", "Remote content editing", "Online survey creation", "Car wash", "Affiliate marketing consulting", "Home theater installation", "Childcare services", "Haircuts and styling", "Social media advertising management", "Online insurance consulting", "Custom merchandise design", "Family financial planning", "Subscription box services", "Remote program design for social change", "Bicycle rentals", "Life management services", "Interior decorating", "Online impact assessment for advocacy campaigns", "Interior paint color consulting", "Moving services", "YouTube channel management", "Camping site management", "Workshops and seminars", "Online brand monitoring", "Content creation", "Dog daycare services", "Digital product design", "Online citizen engagement", "Real estate staging", "Speech writing services", "Online customer service consulting", "Digital engagement strategies for nonprofits", "Online membership program development", "Website traffic analysis", "Mobile game development", "Logistics optimization consulting", "Online fundraising platform setup", "Copywriting", "Custom software development", "Digital marketing strategies for nonprofits", "Screenwriting", "Pool maintenance", "Specialty coffee shop", "Landscaping", "Etsy shop setup", "Mobile app analytics", "Airport shuttle services", "Online courses", "Corporate lunch catering", "Virtual fundraising event planning", "Graphic design", "Virtual customer service", "Digital loyalty cards", "Online fundraising strategies for social change", "Spa treatments", "Business continuity planning", "Political consulting", "Domain registration services", "Online community engagement frameworks", "Ride-hailing services", "Online community organizing", "Supplier diversity consulting", "Interior landscaping", "Online fundraising strategy development", "Virtual design thinking workshops", "Lead generation services", "Remote work tools consulting", "Social media for nonprofits", "Social media giveaways", "Auto insurance", "Remote program design for community organizations", "Outdoor adventure camps", "Voice acting", "Online volunteer management systems", "Remote evaluation tools for community projects", "Web development", "Remote coalition management", "Team dynamics training", "Online fundraising strategy", "Virtual reality experiences", "Digital fundraising campaigns for social causes", "Remote program design for advocacy initiatives", "Bird watching tours", "Outplacement services", "Carpet cleaning", "Online time management training", "Interior architecture", "Virtual business consulting", "Employee recognition programs", "Private tutoring", "Remote program evaluation for advocacy campaigns", "Financial planning", "Online digital engagement strategies", "Remote policy analysis for nonprofits", "Remote coalition building for social good", "Health and wellness coaching for employees", "Event sponsorship consulting", "Meal prep services", "Social media audit services", "Career coaching", "Video editing", "Online community building initiatives", "Event ticketing", "Feedback collection services", "Live streaming services", "Camping gear rental", "Tour bus services", "Social event planning", "Theatrical production services", "Remote program evaluation tools", "Home organization", "Virtual community feedback sessions", "Weight loss programs", "Quality assurance consulting", "Online course creation", "Life skills coaching", "Digital community building", "Virtual reality team training", "Family law consultations", "Art classes", "Online impact measurement for social initiatives", "Virtual community forums", "Telemedicine services", "Personal finance consulting", "Fitness boot camps", "Data visualization services", "Remote community engagement workshops", "Homemade pasta workshops", "Skill development workshops", "Online advocacy campaigns for nonprofits", "Organizational development consulting", "Digital marketing strategies for social change", "Digital storytelling strategies for nonprofits", "Webinar production", "Remote program design for advocacy campaigns", "Online leadership seminars", "Digital advocacy strategies for social good", "Inventory management consulting", "Special event catering", "Online community engagement for social change", "Wine and food pairing events", "Packing services", "Child behavior consulting", "Insurance brokerage", "Corporate gala organization", "Chocolate making classes", "Online fundraising tools for community projects", "Content management systems (CMS)", "Culinary tours", "Social media crisis response", "Podcast production", "Remote evaluation frameworks for social good", "Digital community impact initiatives", "Public festival planning", "Pop-up shop planning", "Landscape architecture", "Henna tattoos", "Candle making workshops", "Online program design for community initiatives", "Storage unit rental", "Parcel delivery", "Online community needs assessment", "International business consulting", "Event ticketing services", "Facility management services", "Online community engagement for social good", "E-commerce customer support", "Creative writing coaching", "Personal training", "Event sponsorship coordination", "Rideshare services", "Virtual advocacy training", "Email marketing services", "Real estate marketing services", "E-commerce store setup", "Training module design", "Wardrobe styling services", "Online review management", "Quality assurance services", "Home staging for real estate", "Market segmentation analysis", "Healthcare marketing consulting", "Productivity coaching", "Online advocacy campaigns", "Digital volunteer coordination", "Digital communication strategy for nonprofits", "Ski and snowboard rentals", "Risk management consulting", "Web design and development", "Crisis response training", "International trade consulting", "Pet insurance", "Remote coalition building for social initiatives", "Public speaking training", "Digital marketing", "Online community partnerships", "Copy editing services", "Food truck catering", "Public speaking coaching", "Digital event marketing", "Remote partnership development", "Fishing charters", "Personal finance coaching", "Accounting services", "Digital storytelling for nonprofit impact", "Homeschooling support", "Lawn care", "Remote partnership development for nonprofits", "Remote fundraising strategy execution", "Supply chain consulting", "Birthday party entertainment", "Brand awareness campaigns", "Virtual fundraising event promotion", "Hypnotherapy", "Online community feedback mechanisms", "Digital marketing for advocacy campaigns", "Conflict resolution services", "Website maintenance", "Digital communication strategies", "Data analysis", "Online networking for community organizations", "Computer repair", "Culinary classes", "Online fundraising tools for social good", "Personal injury law consultations", "Child safety training", "Art commissions", "Shopify store management", "Performance management consulting", "Social media influencer services", "Language classes", "Remote work consulting", "Life insurance", "Videography", "Barbecue catering", "Remote collaboration tools training", "Translation and localization", "User experience assessments", "Sports coaching", "Digital advocacy training", "Gardening and landscaping advice", "Online therapy sessions", "Wellness coaching", "Electric vehicle charging station installation", "Online trade shows", "Personal branding strategy", "Virtual assistant services", "Photo editing services", "Content performance analysis", "Gourmet popcorn business", "Physical therapy", "Online advertising analytics", "Digital storytelling for community organizations", "IT support", "Remote coalition building for advocacy campaigns", "Environmental consulting", "Online business coaching", "Digital marketing analysis", "Space planning services", "Food festival planning", "Public relations services", "Remote coalition building", "Product launch consulting", "Surfing lessons", "Digital marketing for social impact", "Beauty supply retail", "Home organization services", "Brand identity development", "Lifestyle coaching", "Digital marketing for social change initiatives", "Professional organizing for businesses", "Remote program design for social impact", "Home-school consulting", "Online community assessments", "Freelance graphic design", "Food safety training", "Online impact assessment tools for nonprofits", "Kayaking tours", "Remote technical support", "Online program design and evaluation", "Personal styling", "Video content creation for businesses", "Remote volunteer management", "Online community resource mapping", "Brand ambassador programs", "Online community outreach for social good", "Body scrubs", "Digital storytelling for community impact", "Destination event planning", "Fashion consulting", "Family reunion planning", "SEO services", "Digital marketing for social enterprises", "Email newsletter design", "Online community grants management", "Remote evaluation frameworks for community impact", "Nature retreats", "Photo editing", "Online impact assessments for nonprofits", "Remote program funding strategies", "Pressure washing", "Nutrition counseling", "Digital productivity tools consulting", "Guided hiking tours", "Music festival organization", "Aromatherapy", "Online awareness campaigns", "Workflow optimization", "Digital impact measurement for nonprofits", "Health and safety audits", "Content calendar planning", "Social media analytics", "Influencer campaign management", "Remote team building", "Cosmetic surgery consultations", "Podcast hosting", "Online community outreach for nonprofits", "Election campaign services", "Photography", "Remote community building initiatives", "Security consulting", "Public speaking workshops", "Remote IT support", "Online impact storytelling", "Film production services", "Home security systems installation", "Content management system (CMS) support", "Online performance reviews", "Virtual lunch and learn sessions", "Online brand management", "Employee engagement initiatives", "Pet grooming", "Remote event marketing", "Online feedback loops", "Freelance writing coaching", "Digital storytelling for advocacy campaigns", "Online program design for nonprofits", "Eyelash extensions", "Corporate social responsibility consulting", "Digital storytelling for nonprofit initiatives", "Remote digital marketing strategy", "Corporate law consulting", "Online capacity building workshops", "Web hosting services", "Dessert catering", "Event catering", "Remote training facilitation", "Remote coalition building for social enterprises", "Digital communication for advocacy", "Team-building outdoor activities", "Remote work training", "Online community building", "Interior painting services", "Outdoor adventure guiding", "Microblading", "Virtual workshops", "Intellectual property services", "Online content strategy", "Virtual lobby days", "Business analytics services", "DIY craft classes", "Remote stakeholder consultations for nonprofits", "Performance improvement consulting", "Cultural immersion programs", "Digital detox coaching", "Art collection consulting", "Virtual impact assessments", "Advocacy services", "Debt counseling", "Video editing services", "Online icebreaker activities", "Exterior painting services", "Remote fundraising planning for social change", "Personal shopping", "Digital resource allocation", "Remote policy advocacy for social change", "Gourmet food trucks", "Keyword research services", "Nanny services", "Digital marketing strategy for advocacy campaigns", "Video marketing", "Scuba diving classes", "Online fundraising campaign planning", "Chauffeur services", "Social media trend analysis", "Affiliate program management", "Online capacity building for nonprofits", "Content curation services", "Remote agile teams setup", "Online policy advocacy", "Event coordination", "Event food services", "Barber services", "Amazon seller consulting", "Teen mentoring programs", "Nail care", "Content strategy consulting", "Mystery shopping", "Online event coordination", "Music lessons", "Furniture assembly services", "Smart home security installation", "Online language tutoring", "Leadership development programs", "Tax dispute resolution", "Chiropractic care", "App development", "Social impact consulting", "Digital storytelling workshops for nonprofits", "Corporate wellness programs", "Virtual community engagement", "Investment advisory", "Franchise consulting", "Business formation services", "Remote community research", "Corporate training videos", "Dog walking", "Internet of Things (IoT) consulting", "Market research", "Augmented reality applications", "Change management consulting", "Procurement consulting", "Brand strategy consulting", "Online advocacy workshops", "Fitness classes", "Corporate event production", "Digital communication for community initiatives", "Homework help services", "Educational games development", "Ethnic cuisine cooking classes", "Emergency preparedness consulting", "Travel concierge services", "Career transition coaching", "Freelancer management systems", "UX testing", "After-school programs", "Music therapy", "Remote program evaluation for community projects", "Online community engagement tools for nonprofits", "Virtual networking events", "Remote payroll management", "Digital community impact storytelling", "Public health consulting", "Management training", "Digital fundraising strategies for nonprofits", "Digital community outreach", "Crowdsourced community initiatives", "Virtual community outreach initiatives", "Cost reduction consulting", "Network setup", "Outdoor fitness classes", "Web-based market research", "Custom cake design", "Virtual bookkeeping", "Investment coaching", "Brand strategy development", "Remote community outreach strategies", "Digital advocacy initiatives", "Digital advertising management", "Online impact measurement strategies", "Telehealth services", "Children's party planning", "Blockchain development", "Bookkeeping services", "3D modeling and animation", "Bankruptcy consulting", "Online grant application workshops", "Online product validation", "Online program evaluation", "Online store management", "Employee handbook creation", "Mountain biking tours", "Concert and event promotion", "Health insurance", "Digital policy analysis", "Play therapy", "Online tax filing assistance", "Digital advocacy campaigns", "Online board governance training", "Online tech support", "E-book publishing services", "Life coaching", "Facilities planning", "Home energy efficiency audits", "Non-profit management consulting", "Digital collaboration for nonprofits", "Social media content creation", "Debt management services", "Virtual stakeholder engagement workshops", "Meal kit delivery services", "Plant care consulting", "Employee motivation programs", "Digital storytelling for social causes", "Travel agency services", "Virtual stakeholder engagement strategies", "Mental health counseling", "Yoga instruction", "Remote program design for nonprofit initiatives", "Quality management consulting", "Drone photography services", "Online brand workshops", "Onboarding services", "Search engine marketing (SEM)", "Digital storytelling for nonprofit organizations", "Corporate sponsorship management", "Fashion show planning", "Event security", "Software as a Service (SaaS) consulting", "Freelance writing", "Archery lessons", "Roofing services", "Resume writing services", "Online program impact assessment", "Employee benefits consulting", "Food truck services", "Remote program design for nonprofit organizations", "E-learning platform creation", "Remote stakeholder management", "Brand loyalty programs", "Digital project collaboration", "Remote project evaluation", "Business process improvement consulting", "Guided nature walks", "Membership site development", "Virtual office setup", "Travel planning", "Home technology integration", "Meditation retreats", "Interactive content creation", "Organic meal delivery", "Digital advocacy campaigns for social change", "Digital advocacy training for community projects", "Dance instruction", "Online course development", "Online policy development for nonprofits", "Moving organization services", "Customer journey mapping", "Historical consulting", "After-school tutoring", "Online productivity assessments", "Rock climbing instruction", "Pest control", "Wine tasting events", "Digital sponsorship strategies", "Digital fundraising campaign development", "Consumer behavior research", "Lifestyle photography", "Legal transcription", "Travel planning services", "Wedding planning", "Appliance repair", "Virtual civic engagement", "Cultural competency training", "Remote risk management consulting", "Personal assistant services", "Genealogy research", "Limo services", "Remote program evaluation for social initiatives", "Transportation management consulting", "Consumer insights research", "Webinar hosting services", "User experience (UX) design", "Product development consulting", "Podcast editing", "Remote program evaluation for nonprofits", "Virtual hackathons", "Remote program design for nonprofits", "Online community engagement for advocacy projects", "Trade compliance consulting", "Online proofreading services", "Real estate investment consulting", "Web-based training programs", "Business strategy sessions", "Website performance optimization", "Digital communication for social change", "Digital advocacy campaigns for social causes", "Remote coalition building for community projects", "Computer repair services", "Instagram strategy consulting", "Non-profit consulting", "Youth sports coaching", "Home renovation consulting", "Financial literacy workshops", "Remote nonprofit governance training", "Landscape design", "Virtual product demonstrations", "Online surveys and polls", "Brow shaping", "Home automation consulting", "Remote policy development", "Affiliate marketing management", "Corporate catering", "Digital storytelling for community initiatives", "Virtual social impact workshops", "Virtual civic engagement initiatives", "Adult education classes", "Digital marketing for community initiatives", "Email marketing campaigns", "Graphic design for social media", "Virtual team building activities", "Online fundraising execution for nonprofits", "Digital impact assessments", "Skincare treatments", "Bakery products delivery", "Online course platforms", "Vegan meal prep", "Online resource sharing for nonprofits", "Online partnership development for nonprofits", "Crisis management consulting", "Virtual event planning", "Online chat support services", "Crowdfunding for social causes", "Farm-to-table experiences", "Feng Shui consulting", "Child photography", "E-learning module creation", "Online fundraising campaign management", "Remote personal training", "Health and wellness challenges", "Gardening services", "Personal chef", "Voice-over services", "Remote program evaluation for social enterprises", "Foreign language immersion programs", "Digital resource development for nonprofits", "Custom carpentry services", "Digital storytelling for nonprofits", "Blockchain consulting", "Search engine optimization audits", "Online ad campaign management", "Family counseling services", "Influencer marketing", "Digital product roadmap development", "Martial arts training", "Digital storytelling for social enterprises", "Cloud services", "PPC management services", "Cultural competency in the workplace", "Community event planning", "Social media content calendar creation", "Interior styling services", "Digital communication strategies for social good", "Business development consulting", "Advocacy and lobbying services", "Remote workforce strategy", "Child enrichment programs", "Online task management consulting", "Sporting event management", "Social media policy development", "Cybersecurity training", "Digital storytelling for social good", "Home decor consulting", "Meal delivery for special diets", "Social media crisis management", "Telehealth software solutions", "Remote coalition management for social impact", "Scrum training", "Market entry strategy consulting", "Fitness retreats", "Public transportation services", "Social media algorithm optimization", "STEM education programs", "Online fundraising campaigns for nonprofits", "Digital marketing for social causes", "Remote community partnerships for social good", "Remote event coordination for nonprofits", "Online affiliate marketing", "Digital strategy for nonprofits", "Social media engagement strategy", "Remote fundraising planning for social impact", "Creative direction", "Children's art classes", "Waxing services", "Job description writing", "Creative writing workshops", "Digital content creation", "Content distribution strategies", "Golf lessons", "Online resource sharing platforms", "CRM setup and support", "Pilates instruction", "Digital fundraising tools for nonprofits", "Aquarium setup and maintenance", "Remote evaluation frameworks for nonprofits", "Digital advocacy training for nonprofits", "Recruitment services", "Remote impact measurement", "Remote community research methods", "Soft skills training", "Retail consulting", "Online compliance training", "Real estate appraisal", "Digital storytelling for advocacy initiatives", "Organizational consulting", "Digital forensics", "Community building for businesses", "Wildlife photography tours", "Remote project management", "Mobile app optimization", "Baking classes for kids", "Online ideation sessions", "E-commerce for nonprofits", "Electrical services", "Online roundtable discussions", "Online social enterprise strategy", "Customer retention strategies", "Online video training", "Delivery services", "Environmental impact assessments", "Online community building strategies", "Digital storytelling for nonprofit campaigns", "Senior care services", "Car rental", "Cryptocurrency wallet setup", "Remote program design for social good", "Home improvement consulting", "Family photography", "Digital product development", "Crisis communication planning", "Safety training", "Online tutoring", "Corporate communications consulting", "User feedback sessions", "Home brewing classes", "Online market analysis", "Vegan meal preparation", "Public relations", "Podcast launch consulting", "Digital user experience consulting", "Quality assurance testing", "Computer network security", "Content marketing strategy", "Minimalism coaching", "Remote grant management", "Online public relations for nonprofits", "Freight shipping", "Database management", "Networking event organization", "Online public engagement", "Website usability testing", "Estate planning", "User acceptance testing", "Tai Chi instruction", "Butcher shop services", "Crowdfunding consulting", "Online fitness coaching", "Home inspection services", "Wardrobe consulting", "Online PR strategies", "Social media strategy development", "Digital storytelling for advocacy organizations", "Immigration services", "Food delivery", "College admissions counseling", "Property management services", "Home appraisal services", "Digital marketing for nonprofit initiatives", "Digital communication tools for advocacy", "Online volunteer recruitment strategies", "Floral arrangement services", "Digital communication for nonprofit organizations", "Online therapy", "Gutter cleaning", "Remote UX research", "Agile project management coaching", "Holiday party planning", "Remote agile coaching", "Online quality assurance services", "Branding photography", "Online reputation management", "User interface (UI) design", "Mobile device repair", "Makeup services", "Technical writing", "Digital advocacy workshops for nonprofits", "Virtual reality development", "E-commerce solutions", "Long-distance moving", "Digital community research tools", "Employee onboarding services", "Content marketing consulting", "Online community outreach for social causes", "Digital nomad services", "Pediatric therapy", "Cooking demonstrations", "Corporate event planning", "Online fundraising strategies", "Animation services", "Personal branding coaching", "Parenting workshops", "Philanthropic consulting", "Digital fundraising campaign execution", "House cleaning", "Disaster recovery planning", "Referral program development", "Customer service training", "Personal branding workshops", "Acupuncture", "SEO keyword analysis", "Home energy audits", "Online volunteer recruitment", "Virtual fundraising strategies", "Courier services", "Remote evaluation for social impact initiatives", "Website auditing", "Logistics consulting", "Mobile beauty services", "Illustration", "Smart home installation", "Online fundraising services", "Collaborative project management", "Interior design", "Investment property management", "Virtual exit interviews", "Digital content management", "Culinary nutrition coaching", "Customer satisfaction surveys", "Mobile-friendly website design", "Martial arts classes", "Digital brainstorming workshops", "HR consulting", "Tanning salons", "Remote troubleshooting", "Remote product testing", "Online social media management for nonprofits", "Solar panel installation", "Horse riding lessons", "Farmers market vendors", "Event planning", "Online storytelling for social impact", "Health coaching", "Art therapy", "Remote fundraising strategies for nonprofits", "Online stakeholder consultations", "Restaurant consulting", "Lifestyle blog consulting", "Pet grooming services", "SAT/ACT preparation", "Hair coloring", "GED preparation courses", "Office cleaning services", "Legal consulting", "Digital fundraising platforms", "Conflict resolution training", "Digital transformation consulting", "Online community resource sharing", "Massage therapy", "Corporate retreat planning", "Media relations consulting", "Nutrition workshops", "Public policy consulting", "Remote program design for community impact", "Virtual peer networking", "Remote organizational development for nonprofits", "Remote stakeholder mapping", "Print design services", "Bicycle repair services", "E-learning platform development", "New parent support services", "Plumbing services", "Influencer partnership management", "Crowdsourcing for social good", "Craft cocktail classes", "Business networking events", "Art exhibition organization", "Pet training", "Valet services", "Remote accessibility consulting", "Online fundraising campaigns for community impact", "Content syndication services", "Personal concierge services", "Handyman services", "Website SEO audit", "Workplace safety training", "Catering services", "Remote non-profit board training", "Paintball services", "Remote evaluation for social impact projects", "Sustainable living consulting", "Personal development coaching", "Home care services for the elderly", "Trade show exhibition services", "Notary services", "Sustainability consulting", "Remote project oversight", "Online reputation repair", "Meditation classes", "Digital asset management", "Market entry consulting", "Charity event planning"],
)

long_service_list = DynamicProvider(
    provider_name="long_services",
     elements= ["Digital communication strategies for advocacy campaigns", "Digital communication strategies for advocacy organizations", "Remote evaluation frameworks for advocacy campaigns", "Digital marketing strategies for nonprofit campaigns", "Remote fundraising planning for nonprofit organizations", "Remote fundraising planning for social enterprises", "Remote program evaluation for advocacy organizations", "Online community engagement for nonprofit organizations", "Online partnership development for advocacy initiatives", "Online volunteer management systems for nonprofits", "Online partnership development for advocacy campaigns", "Digital communication tools for community projects", "Online fundraising strategies for community projects", "Remote program evaluation for community organizations", "Online partnership development for community impact", "Online fundraising planning for nonprofit organizations", "Digital communication strategies for nonprofit campaigns", "Online fundraising strategies for advocacy initiatives", "Remote community building strategies for nonprofits", "Digital marketing strategies for community engagement", "Remote program evaluation for nonprofit initiatives", "Digital advocacy strategies for community organizations", "Remote community building initiatives for social impact", "Online fundraising execution for community organizations", "Online fundraising strategies for social initiatives", "Remote coalition building for nonprofit organizations", "Remote community building initiatives for social enterprises", "Remote coalition management for community projects", "Online impact measurement strategies for community organizations", "Online impact measurement for community initiatives", "Virtual evaluation frameworks for community initiatives", "Remote fundraising planning for nonprofit campaigns", "Online fundraising execution for advocacy organizations", "Digital marketing strategies for community organizations", "Remote fundraising strategies for advocacy campaigns", "Digital communication strategies for community engagement", "Online impact measurement for nonprofit organizations", "Online fundraising campaigns for community organizations", "Online volunteer recruitment strategies for nonprofits", "Digital communications for community organizations", "Online fundraising execution for community projects", "Online fundraising campaigns for social enterprises", "Remote coalition management for social enterprises", "Digital marketing strategies for advocacy campaigns", "Remote evaluation frameworks for social change initiatives", "Online fundraising execution for social initiatives", "Digital communication strategies for social enterprises", "Remote fundraising planning for community organizations", "Online fundraising campaigns for community initiatives", "Remote community partnerships for nonprofit initiatives", "Remote coalition building for advocacy initiatives", "Digital advocacy strategies for community initiatives", "Online fundraising strategies for community organizations", "Remote program evaluation for advocacy initiatives", "Remote coalition management for advocacy initiatives", "Online community outreach for advocacy initiatives", "Remote program evaluation for social impact projects", "Online impact measurement for community organizations", "Remote evaluation frameworks for nonprofit organizations", "Online fundraising campaigns for nonprofit initiatives", "Online fundraising strategies for community impact", "Remote stakeholder engagement for community projects", "Online partnership development for social change initiatives", "Digital marketing strategy for community engagement", "Digital advocacy training for community organizations", "Online fundraising campaigns for nonprofit organizations", "Remote community building initiatives for nonprofit organizations", "Online community engagement strategies for nonprofits", "Remote community partnerships for advocacy organizations", "Remote community partnerships for nonprofit projects", "Remote fundraising planning for advocacy campaigns", "Online impact assessment for community initiatives", "Digital communication strategies for social impact", "Online community outreach initiatives for nonprofits", "Online partnership development for social initiatives", "Online impact assessment frameworks for nonprofits", "Digital fundraising campaigns for community impact", "Remote fundraising execution for advocacy campaigns", "Online resource development for social enterprises", "Online fundraising strategies for social enterprises", "Remote coalition building for nonprofit initiatives", "Digital communication strategies for nonprofit initiatives", "Online partnership development for community initiatives", "Online partnership development for nonprofit projects", "Digital marketing strategies for advocacy organizations", "Remote program evaluation for social change initiatives", "Digital communication tools for advocacy organizations", "Remote evaluation frameworks for nonprofit initiatives", "Remote evaluation frameworks for advocacy organizations", "Remote coalition management for social initiatives", "Online fundraising campaign execution for nonprofits", "Online fundraising campaigns for social initiatives", "Remote community building initiatives for nonprofits", "Online fundraising execution for advocacy campaigns", "Remote program evaluation frameworks for social change", "Online program evaluation for community organizations", "Online impact assessment for community organizations", "Digital marketing strategies for social initiatives"],
)


def generate_service_name():

    # Initialize Faker instance
    fake = Faker()
    # then add new provider to faker instance
    fake.add_provider(service_list)

    service_name = fake.services()
    
    return service_name

def generate_long_service_name():

    # Initialize Faker instance
    fake = Faker()
    # then add new provider to faker instance
    fake.add_provider(long_service_list)

    service_name = fake.long_services()
    
    return service_name