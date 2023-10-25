*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags  NextAvailableSchedule
Library     Collections
Library     String
Library     json
Library     requests
Library     random
Library     FakerLibrary
# Library    FakerLibrary    locale=en_IN
# Library     /ebs/TDD/db.py
Library     /ebs/TDD/Keywordspy.py
# Library      /ebs/TDD/test.py
Resource    /ebs/TDD/ProviderKeywords.robot
Resource    /ebs/TDD/ConsumerKeywords.robot
Resource    /ebs/TDD/SuperAdminKeywords.robot
Variables   /ebs/TDD/varfiles/providers.py
Variables   /ebs/TDD/varfiles/hl_musers.py
Variables   /ebs/TDD/varfiles/consumerlist.py
Variables   /ebs/TDD/varfiles/consumermail.py

*** Variables ***
@{langs}   assamese  bengali  english  gujarati  hindi  kannada  Konkani  malayalam  Marathi  manipuri  oriya  punjabi  rajasthani  sanskrit  tamil  telugu  urdu  arabic
${CC1}      +44 7911
${US_CC}   +1

*** Keywords ***

Get Date Time via Timezone
    [Arguments]    ${timezone}
    ${zone}  @{loc}=  Split String    ${timezone}  /
    ${type}=    Evaluate     type($loc).__name__
    ${loc}=  Random Element    ${loc}
    # IF  type($loc).__name__ == 'list'
    #     ${loc}=  Random Element    ${loc}
    # END
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  provider/location/date/${zone}/${loc}  expected_status=any
    [Return]  ${resp}


*** Test Cases ***  
Testing timezones

    # random.choices(test_list, k=4)
    ${splitCC}=  Split String    ${CC1}  separator=${SPACE}  max_split=1
    ${CC1}=  Set Variable  ${splitCC}[0]

    ${splitCC}=  Split String    ${US_CC}  separator=${SPACE}  max_split=1
    ${US_CC}=  Set Variable  ${splitCC}[0]

***COMMENT***
    Log List   ${langs}
    ${Languages}=  random.choices  ${langs}  k=5
    Log  ${Languages}
    ${Languages}=  random.choices  ${langs}  k=3
    Log  ${Languages}
    ${Languages}=  random.choices  ${langs}  k=8
    Log  ${Languages}
    ${Languages}=  random.choices  ${langs}  
    Log  ${Languages}
    ${Languages}=  random.choices  ${langs}  
    Log  ${Languages}
    ${Languages}=  random.choices  ${langs}  
    Log  ${Languages}
    ${Languages}=  random.choices  ${langs}  
    Log  ${Languages}

    ${Languages}=  Words   ext_word_list=@{langs}  nb=5  unique=True
    Log  ${Languages}
    ${Languages}=  Words   ext_word_list=@{langs}   nb=3  unique=True
    Log  ${Languages}
    ${Languages}=  Words   ext_word_list=@{langs}   nb=8  unique=True
    Log  ${Languages}
    ${Languages}=  Words   ext_word_list=@{langs}    unique=True
    Log  ${Languages}
    ${Languages}=  Words   ext_word_list=@{langs}  unique=True
    Log  ${Languages}
    ${Languages}=  Words   ext_word_list=@{langs}  unique=True
    Log  ${Languages}
    
    ${Languages}=  Random Elements   elements=@{langs}  length=5  unique=True
    Log  ${Languages}
    ${Languages}=  Random Elements   elements=@{langs}  length=3  unique=True
    Log  ${Languages}
    ${Languages}=  Random Elements   elements=@{langs}  length=8  unique=True
    Log  ${Languages}
    ${Languages}=  Random Elements   elements=@{langs}  unique=True
    Log  ${Languages}
    ${Languages}=  Random Elements   elements=@{langs}  unique=True
    Log  ${Languages}
    ${Languages}=  Random Elements   elements=@{langs}  unique=True
    Log  ${Languages}


    
*** comment ***

    ${PH1}  FakerLibrary.Phone Number
    ${PH1}  FakerLibrary.Phone Number
    ${PH1}  FakerLibrary.Phone Number
    ${PH1}  FakerLibrary.Phone Number
    ${CC1}  country_calling_code
    ${CC1}  country_calling_code
    ${CC1}  country_calling_code
    ${CC1}  country_calling_code
    ${CC1}  country_calling_code

*** comment ***
    # Ref: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    # Ref: https://www.nationsonline.org/oneworld/country_code_list.htm

    ${status}  ${value}  Run Keyword And Ignore Error  FakerLibrary.Local Latlng  country_code=AE  coords_only=False    #UAE -    Asia/Dubai
    ${status}  ${value}  Run Keyword And Ignore Error  FakerLibrary.Local Latlng  country_code=OM  coords_only=False      #OMAN -   Asia/Dubai, Asia/Muscat
    ${status}  ${value}  Run Keyword And Ignore Error  FakerLibrary.Local Latlng  country_code=QA  coords_only=False      #Qatar -  	Asia/Qatar
    ${status}  ${value}  Run Keyword And Ignore Error  FakerLibrary.Local Latlng  country_code=BH  coords_only=False      #Bahrain -  	Asia/Qatar
    ${value}  FakerLibrary.Local Latlng  country_code=SA  coords_only=False      #saudi arabia-                         Asia/Riyadh
    ${status}  ${value}  Run Keyword And Ignore Error  FakerLibrary.Local Latlng  country_code=KW  coords_only=False      #Kuwait -  	Asia/Riyadh, Asia/Kuwait
    ${value}  FakerLibrary.Local Latlng  country_code=YE  coords_only=False      #Yemen-             	Asia/Riyadh, Asia/Aden
    ${value}  FakerLibrary.Local Latlng  country_code=IR  coords_only=False      #Iran -   Asia/Tehran
    ${value}  FakerLibrary.Local Latlng  country_code=IQ  coords_only=False      #Iraq -     	Asia/Baghdad
    ${status}  ${value}  Run Keyword And Ignore Error  FakerLibrary.Local Latlng  country_code=ER  coords_only=False     #Eritrea-      Africa/Asmara
    ${value}  FakerLibrary.Local Latlng  country_code=PK  coords_only=False      #Pakistan -        Asia/Karachi
    ${value}  FakerLibrary.Local Latlng  country_code=DJ  coords_only=False     #Djibouti-  Africa/Djibouti, Africa/Nairobi
    ${value}  FakerLibrary.Local Latlng  country_code=AF  coords_only=False     #Afghanistan- Asia/Kabul
    ${status}  ${value}  Run Keyword And Ignore Error  FakerLibrary.Local Latlng  country_code=JO  coords_only=False     #Jordan-  Asia/Amman
    ${value}  FakerLibrary.Local Latlng  country_code=SY  coords_only=False     #Syria-   	Asia/Damascus
    ${value}  FakerLibrary.Local Latlng  country_code=IL  coords_only=False     #Israel -   Asia/Jerusalem, Asia/Tel_Aviv
    ${value}  FakerLibrary.Local Latlng  country_code=PS  coords_only=False     #Palestinian Territory-     Asia/Gaza
    ${status}  ${value}  Run Keyword And Ignore Error  FakerLibrary.Local Latlng  country_code=TM  coords_only=False     #Turkmenistan-  Asia/Ashgabat, Asia/Ashkhabad
    ${status}  ${value}  Run Keyword And Ignore Error  FakerLibrary.Local Latlng  country_code=LB  coords_only=False     #Lebanon-   	Asia/Beirut
    ${value}  FakerLibrary.Local Latlng  country_code=EG  coords_only=False     #Egypt-     Africa/Cairo
    ${value}  FakerLibrary.Local Latlng  country_code=ET  coords_only=False     #Ethiopia-       	Africa/Addis_Ababa, Africa/Nairobi
    
    # ${latti}  ${longi}  ${city}  ${country_abbr}  ${AE_tz}=  FakerLibrary.Local Latlng  country_code=AE  coords_only=False
    # ${latti}  ${longi}  ${city}  ${country_abbr}  ${AE_tz}=  FakerLibrary.Local Latlng  country_code=ARE  coords_only=False
    
    
*** comment ***

    Log  ${CURDIR}
    Log  ${EXECDIR} 
    ${envs}=   Get Environment Variables
    Log  ${envs} 
    
    ${tz}=  create_tz  America/Indiana/Indianapolis
    ${tz}=  test.create_tz  America/Indiana/Indianapolis
    ${tz}=  test.create_tz  America/Indiana/Indianapolis
    ${tz}=  test.create_tz  America/Indiana/Indianapolis
    # ${tz}=  Keywordspy.create_tz  Asia/Kolkata
    
    ${time}=   db.get_time_by_timezone   America/Indiana/Indianapolis

    ${time}=   db.get_time_by_timezone   Asia/Kolkata
    
    ${resp}=  Get Date Time via Timezone   America/Indiana/Indianapolis
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Date Time via Timezone   Asia/Kolkata
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${path1} 	${dir} = 	Split Path   America/Indiana/Indianapolis
    # ${path1} 	${dir} = 	Split Path   Asia/Kolkata
    # ${str} = 	Replace String Using Regexp 	America/Indiana/Indianapolis 	\\/\(\.+\){2} 	${EMPTY} 	count=1
    # ${str} = 	Replace String Using Regexp 	America/Indiana/Indianapolis  \(\\/.*\)\{2\}  ${EMPTY}
    # ${matches} = 	Get Regexp Matches 	America/Indiana/Indianapolis 	^.*/
    # ${ts} =  Evaluate  1523126888080/1000
    # ${start_time}=    DateTime.Convert Date    ${ts}   result_format="%a, %d %b %Y"


    ${rand_loc}=  FakerLibrary.Local Latlng
    ${rand_loc}=  FakerLibrary.Local Latlng  country_code=US  coords_only=True
    ${rand_loc}=  FakerLibrary.Local Latlng  country_code=IN  
    ${rand_loc}=  FakerLibrary.Local Latlng  country_code=IN  coords_only=True
    ${rand_loc}=  FakerLibrary.Local Latlng  country_code=IE  coords_only=False
    ${rand_loc}=  FakerLibrary.Local Latlng  country_code=IE  coords_only=True
    ${Locale} =  FakerLibrary.Locale
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${tz}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${pin}=  FakerLibrary.postcode

    ${resp}=  Get Date Time by Timezone  ${tz}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get LocationsByPincode  ${pin}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${zone} 	${loc}=  Split String    Pacific/Apia   /
    # ${zone} 	${loc}=  Split String    US/Samoa   /
    # ${zone} 	${loc}=  Split String    America/Atka  /
    # ${zone} 	${loc}=  Split String    Asia/Kolkata  /
    # ${zone} 	${loc}=  Split String    Asia/Kuwait   /

    # Get Date Time via Timezone  
    # ${resp}=  Get Date Time via Timezone   Pacific/Apia
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Date Time via Timezone   Asia/Kolkata
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Date Time via Timezone   Asia/Kuwait
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Date Time via Timezone   America/Atka
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Date Time via Timezone   US/Samoa
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${time}=   db.get_time_by_timezone   Pacific/Apia
    # ${time}=   db.get_time_by_timezone   Asia/Kolkata
    # ${time}=   db.get_time_by_timezone   Asia/Kuwait
    # ${time}=   db.get_time_by_timezone   America/Atka
    # ${time}=   db.get_time_by_timezone   US/Samoa

    # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}

    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${tz2}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}

    # ${latti}  ${longi}=  get_lat_long
    # ${tz3}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}

    # ${foreign_tz}=   db.get_Timezone_by_lat_long   42.58765  1.74028
    # ${time}=   db.get_time_by_timezone   ${foreign_tz}
    # ${resp}=  Get Date Time via Timezone   ${foreign_tz}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${sTime}=  add_timezone_time  ${tz1}  0  15  
    # ${sTime}=  add_timezone_time  ${tz2}  0  15  
    # ${sTime}=  add_timezone_time  ${tz3}  0  15

    # ${sTime}=  add_timezone_time  ${foreign_tz}  0  15

    # ${rand_tz}=  FakerLibrary.Timezone
    # ${rand_tz}=  FakerLibrary.Timezone
    # ${rand_tz}=  FakerLibrary.Timezone
    # ${rand_tz}=  FakerLibrary.Timezone
    # ${time}=   db.get_time_by_timezone   ${rand_tz}
    # ${resp}=  Get Date Time via Timezone   ${rand_tz}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${sTime}=  add_timezone_time  ${rand_tz}  0  15  

    # ${time}=   db.get_time_by_timezone   thrissur/kerala