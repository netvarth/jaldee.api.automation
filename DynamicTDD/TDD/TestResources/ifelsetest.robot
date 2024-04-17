*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags  Testing
Library     Collections
Library     String
Library     json
Library     requests
Library     RequestsLibrary
Library     FakerLibrary
# Library    FakerLibrary    locale=en_IN
# Library   FakerLibrary   WITH NAME   faker
Library     /ebs/TDD/db.py
# Resource    /ebs/TDD/ProviderKeywords.robot
# Resource    /ebs/TDD/ConsumerKeywords.robot
# Resource    /ebs/TDD/SuperAdminKeywords.robot
# Variables   /ebs/TDD/varfiles/providers.py
# Variables   /ebs/TDD/varfiles/hl_musers.py
# Variables   /ebs/TDD/varfiles/consumerlist.py
# Variables   /ebs/TDD/varfiles/consumermail.py


*** Variables ***
${latti}         ${-0.190822}
${longi}    ${-68.031759}
${latti1}         ${0.190822}
${longi1}    ${68.031759}
${word1}        Python
${word2}        PYTHON
${word3}        python

*** Test Cases ***  

Testing python lower fn

    ${s_id}=  Set Variable  ${NONE}
    ${srv_val}=    Get Variable Value    ${s_id}

    log  ${word1.lower()}
    log  ${word2.lower()}
    log  ${word3.lower()}

*** Comments ***

Check empty Dictionary

    ${s_id}=  Set Variable  ${NONE}
    ${srv_val}=    Get Variable Value    ${s_id}
    
    ${whatsApp}=  Create Dictionary
    ${telegram}=  Create Dictionary
    IF  ${whatsApp} == &{EMPTY}
        Log    whatsApp is empty
    ELSE 
        Log  whatsapp is not empty
    END

    IF  ${telegram} == &{EMPTY}
        Log    Telegram is empty
    ELSE 
        Log  Telegram is not empty
    END

    ${primnum}                    FakerLibrary.Numerify   text=%%%%%%%%%%
    ${altno}                      FakerLibrary.Numerify   text=%%%%%%%%%%
    # ${numt}                       FakerLibrary.Numerify   text=%%%%%%%%%%
    # ${numw}                       FakerLibrary.Numerify   text=%%%%%%%%%%

    ${whatsApp}=               Create Dictionary    countryCode=+91   number=${primnum}
    ${telegram}=               Create Dictionary    countryCode=+91   number=${altno}

    IF  ${whatsApp} != &{EMPTY}
        Log  whatsapp is not empty
    ELSE 
        Log    whatsApp is empty
    END

    IF  ${telegram} != &{EMPTY}
        Log  Telegram is not empty
    ELSE 
        Log    Telegram is empty
    END


Testing py fn

    Log  ${TEST NAME}
    Log  ${SUITE NAME}
    db.get_Host_name_IP
    ${rand_ph}=  FakerLibrary.Phone Number
    ${Locale} =  FakerLibrary.Locale
    # ${output}   FakerLibrary.Init 	locale=${Locale}  providers=None   seed=None
    # ${output}   FakerLibrary.Init 	locale=en_IN
    ${rand_ph}=  FakerLibrary.Phone Number
    

Testing named arguments

    ${auth} =    Create List    Mark    SuperSecret
    ${params} =    Create Dictionary    type=Condos    filter=2Bedrooms
    Create Session    testingapi    url=http://postman-echo.com    auth=${auth}
    ${resp} =    GET On Session    testingapi   /get    params=${params}
    ${json} =  To JSON  ${resp.content}  pretty_print=True
    Log  \n${json}  console=yes



Testing named arguments
    
    ${rand_tz}=  FakerLibrary.Timezone

    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${tz}=   db.get_Timezone_by_lat_long   ${latti1}  ${longi1}


    ${zone} 	${loc}=  Split String    Pacific/Apia   /
    ${zone} 	${loc}=  Split String    US/Samoa   /
    ${zone} 	${loc}=  Split String    America/Atka  /
    ${zone} 	${loc}=  Split String    Asia/Kolkata  /
    ${zone} 	${loc}=  Split String    Asia/Kuwait   /

    # Get Date Time via Timezone  
    ${resp}=  Get Date Time via Timezone   Pacific/Apia
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Date Time via Timezone   Asia/Kolkata
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Date Time via Timezone   Asia/Kuwait
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Date Time via Timezone   America/Atka
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Date Time via Timezone   US/Samoa
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${time}=   db.get_time_by_timezone   Pacific/Apia
    ${time}=   db.get_time_by_timezone   Asia/Kolkata
    ${time}=   db.get_time_by_timezone   Asia/Kuwait
    ${time}=   db.get_time_by_timezone   America/Atka
    ${time}=   db.get_time_by_timezone   US/Samoa

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}

    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}

    ${latti}  ${longi}=  get_lat_long
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}

    # ${tz}=   db.get_Timezone_by_lat_long   42.58765  1.74028

    ${sTime}=  add_timezone_time  ${tz}  0  15  


    
# Testing

#     ${domresp}=  get_iscorp_subdomains  0
#     Log  ${domresp}
#     ${dlen}=  Get Length  ${domresp}
#     ${d1}=  Random Int   min=0  max=${dlen-1}
#     Set Test Variable  ${dom}  ${domresp[${d1}]['domain']}
#     Set Test Variable  ${sub_dom}  ${domresp[${d1}]['subdomains']}
    
#     ${licresp}=   Get Licensable Packages
#     Should Be Equal As Strings   ${licresp.status_code}   200
#     ${liclen}=  Get Length  ${licresp.json()}
#     FOR  ${pos}  IN RANGE  ${liclen}
#         Set Suite Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
#         Set Suite Variable  ${pkg_name}  ${licresp.json()[${pos}]['displayName']}
#     END
    
#     # ${NeededString}=    Fetch From Left    Raigarh(MH)    (

#     # ${NeededString}=    Fetch From Left    Raigarh    (

*** Comments ***
country_locale
    ${Language_code} =  FakerLibrary.Language_code
    ${Locale} =  FakerLibrary.Locale
    # ${output} =  catenate
    # ...             ${\n}Language_code: ${Language_code}
    # ...             ${\n}Locale: ${Locale}
    # log   ${output}
    ${state}=  FakerLibrary.State
    ${loc}=  FakerLibrary.Location On Land
    ${latlong}=  FakerLibrary.Local Latlng  country_code=IN
    ${cur_cty}=  FakerLibrary.current country
    ${city}=  FakerLibrary.City
    ${address}=  FakerLibrary.address
    ${phno}=  FakerLibrary.phone number
    ${occupation} =  FakerLibrary.job
    ${admin_unit} =  FakerLibrary.administrative unit
    # ${sec_add}=  FakerLibrary.Secondary Address
    ${street}=  FakerLibrary.Street Name
    ${index}    Generate Random String    length=4    chars=[NUMBERS]

    Add Provider   Microservice

    ${resoucesRequired}=   Random Int   min=1   max=10
    ${maxbookings}=   Random Int   min=1   max=10
    ${leadTime}=   Random Int   min=1   max=5
    Testing kwargs   leadTime=${leadTime}   maxBookingsAllowed=${maxbookings}  isPrePayment=${bool[1]}  resoucesRequired=${resoucesRequired}


