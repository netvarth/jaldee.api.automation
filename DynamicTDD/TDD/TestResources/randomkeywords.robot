*** Settings ***
Library           Collections
Library           BuiltIn

*** Variables ***
&{billable_domains}    healthCare=physiciansSurgeons,dentists,alternateMedicinePractitioners,hospital,dentalHosp,alternateMedicineHosp,laboratory,pharmacy,holisticHealth,psychology    personalCare=beautyCare,personalFitness,massageCenters    foodJoints=restaurants,caterer,homebaker,bakery,juiceParlour,iceCreamParlour,homefood,coffeeShop,sweetShop    professionalConsulting=lawyers,charteredAccountants,taxConsultants,civilArchitects,financialAdviser,stockbroker,auditor,geologist,companySecretary    vastuAstrology=vastu,Astrologer    religiousPriests=temple,poojari    veterinaryPetcare=veterinarydoctor,petcare,veterinaryhospital    retailStores=groceryShops,supermarket,hypermarket,store    otherMiscellaneous=miscellaneous    educationalInstitution=schools,colleges,educationalTrainingInstitute    sportsAndEntertainement=sports,entertainment    communitySocietyAssociation=housingSociety,clubAssociation,hostel    transportation=freightLogistics

*** Keywords ***
Select Random Key And Value
    ${keys}    Get Dictionary Keys    ${billable_domains}
    ${random_key}    Evaluate    random.choice(keys)    random
    ${values}    Get From Dictionary    ${billable_domains}    ${random_key}
    ${random_value}    Evaluate    random.choice(values)    random
    Log    Randomly selected key: ${random_key}
    Log    Randomly selected value: ${random_value}

Select Random Key And Value
    ${random_key}    Evaluate    random.choice(list(billable_domains.keys()))    random
    ${random_value}    Evaluate    random.choice(billable_domains[random_key])    random
    Log    Randomly selected key: ${random_key}
    Log    Randomly selected value: ${random_value} 