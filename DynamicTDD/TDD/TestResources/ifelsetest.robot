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
Library     DateTime
# Library    FakerLibrary    locale=en_IN
# Library   FakerLibrary   WITH NAME   faker
Library     /ebs/TDD/db.py
# Library     if.py
# Resource    /ebs/TDD/ProviderKeywords.robot
# Resource    /ebs/TDD/ConsumerKeywords.robot
# Resource    /ebs/TDD/SuperAdminKeywords.robot
# Variables   /ebs/TDD/varfiles/providers.py
# Variables   /ebs/TDD/varfiles/hl_providers.py
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
@{cancelReason}             noshowup  blocked  closingSoon  tooFull  self  prePaymentPending  QueueDisabled  holiday
@{PO_Number}   ${56}  ${0586185393}

# [LOWER] 	Lowercase ASCII characters from 'a' to 'z'.
# [UPPER] 	Uppercase ASCII characters from 'A' to 'Z'.
# [LETTERS] 	Lowercase and uppercase ASCII characters.
# [NUMBERS] 	Numbers from 0 to 9.

*** Keywords ***

check kwargs
    [Arguments]   &{kwargs}
    ${headers2}=     Create Dictionary    Content-Type=application/json
    ${has_key}=  Evaluate  'Authorization' in ${kwargs}
    IF  ${has_key}
        ${auth_dict}  ${kwargs}  GetFromDict  Authorization  &{kwargs}
        Set To Dictionary 	${headers2}  &{auth_dict}
    ELSE IF  $token
        Set To Dictionary 	${headers2}  Authorization=${token}
    END

# pass var values
#     [Arguments]   ${ph1}  ${ph2}

#     ${ph1}=  Set Variable  ${ph1.strip()}
#     ${ph2}=  Set Variable  ${ph2.strip()}
    
#     IF    '$ph1' != '${NONE}' AND '$ph2' != '${NONE}'
#         ${ph_nos}=  Create List  ${ph1}  ${ph2}
#     ELSE IF    '${ph1}' != ''
#         ${ph_nos}=  Create List  ${ph1}
#     ELSE IF    '${ph2}' != ''
#         ${ph_nos}=  Create List  ${ph2}
#     ELSE
#         ${ph_nos}=  Create List
#     END
#     Log   ${ph_nos}



*** Test Cases ***  

cheking if variable is empty

    Set Test Variable  ${token}   Some Token
    Run Keyword And Continue On Failure  check kwargs   Authorization=${token}
    Run Keyword And Continue On Failure  check kwargs
    Set Suite Variable    ${token}   Some Token
    Run Keyword And Continue On Failure  check kwargs

    # ${PO_Number}=  random_phone_num_generator  subscriber_number_length=10  cc=2
    # Log Many  ${PO_Number}  
    # ${length}=    Get Length    int(${PO_Number[1]})
    # ${length}=    Evaluate    len(str(int(str(${PO_Number[1]}).lstrip('0'))))
    # ${length}=    Evaluate    len(str(int('${PO_Number[1]}'.lstrip('0'))))

    
    # pass var values  ${EMPTY}  ${EMPTY}
    # pass var values  ${NONE}  ${NONE}
    # ${phoneNumbers}=  if.is_string_empty  ${EMPTY}  ${EMPTY}
    # Log  ${phoneNumbers}
    # ${phoneNumbers}=  if.is_string_empty  ${NONE}  ${NONE}
    # Log  ${phoneNumbers}
    # ${ph_nos1} =  Create Dictionary  label= Nicole Miller  resource= PhoneNo  instance= 1180668165  permission= customersOnly
    # ${ph_nos2} =  Create Dictionary  label= Lauren Gibson  resource= PhoneNo  instance= 1190668169  permission= customersOnly
    # # pass var values  ${ph_nos1}  ${ph_nos2}
    # ${phoneNumbers}=  if.is_string_empty  ${ph_nos1}  ${ph_nos2}
    # Log  ${phoneNumbers}

    


*** Comments ***

# *** Keywords ***
# Check kwargs
#     [Arguments]   &{DICT}
#     FOR    ${item}    IN    &{DICT}
#         Log  ${item}
#         Log    Key is '${item}[0]' and value is '${item}[1]'.
#     END

Cheking files exists

    # Create Directory   ${EXECDIR}/TDD/${ENVIRONMENT}data/
    # Create Directory   ${EXECDIR}/data/${ENVIRONMENT}_varfiles/

    # ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    # ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    # ${ph1}=  Set Variable  ${EMPTY}
    # ${ph2}=  Set Variable  ${EMPTY}
    ${null_list}=  Create List  ${EMPTY}  ${NONE}
    ${ph1}=  Set Variable  ${NONE}
    ${ph2}=  Set Variable  ${NONE}
    # ${ph1.strip()}
    # ${ph2.strip()}
    # IF  not ${ph1.strip()}
    #     Log  nothing
    # END
    # IF    not ${items}
    IF  '${ph1}' != '${EMPTY}' and '${ph1}' != '${NONE}' and '${ph2}' != '${EMPTY}' and '${ph2}' != '${NONE}'
        ${ph_nos}=  Create List  ${ph1}  ${ph2}
    # ELSE IF  '${ph1}' != '${NONE}' and '${ph2}' != '${NONE}'
    #     ${ph_nos}=  Create List  ${ph1}  ${ph2}
    ELSE
        ${ph_nos}=  Create List
    END
    # IF  '${ph1}' != '${EMPTY}' and '${ph2.strip()}' != '${EMPTY}'
    # IF  '${ph1}' not in @{null_list} and '${ph2}' not in @{null_list}
    #     ${ph_nos}=  Create List  ${ph1}  ${ph2}
    # ELSE
    #     ${ph_nos}=  Create List
    # END
    # ${ph_nos}=  Create List  ${ph1.strip()}  ${ph2.strip()}
    Log  ${ph_nos}
        
    ${data_dir_path}=  Set Variable    ${EXECDIR}/TDD/${ENVIRONMENT}data/
    ${var_dir_path}=  Set Variable    ${EXECDIR}/data/${ENVIRONMENT}_varfiles/
    ${file_name}=    Set Variable    ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py

    IF  ${{os.path.exists($data_dir_path)}} is False
        Log  Data Directory exists
    ELSE
        Log  Data Directory Doesn't Exist
    END

    IF  ${{os.path.exists($var_dir_path)}} is False
        Log  Var Directory exists
    ELSE
        Log  Var Directory Doesn't Exist
    END

    IF  ${{os.path.exists($file_name)}} is False
        Log  File exists
    ELSE
        Log  File Doesn't Exist
    END

*** Comments ***

Testing python lower fn

    ${date} = 	DateTime.Get Current Date 	
    ${reason}=  Random Element  ${cancelReason}
    ${message}=   FakerLibrary.sentence
    Check kwargs  cancelReason=${reason}  communicationMessage=${message}   date=${date}
    
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
    Create Session    testingapi    url=http=//postman-echo.com    auth=${auth}  verify=true
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
    # ...             ${\n}Language_code= ${Language_code}
    # ...             ${\n}Locale= ${Locale}
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


