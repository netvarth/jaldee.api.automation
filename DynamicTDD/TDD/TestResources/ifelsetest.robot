*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags  NextAvailableSchedule
Library     Collections
Library     String
Library     json
Library     requests
# Library     FakerLibrary
Library    FakerLibrary    locale=en_IN
Library     /ebs/TDD/db.py
Resource    /ebs/TDD/ProviderKeywords.robot
Resource    /ebs/TDD/ConsumerKeywords.robot
Resource    /ebs/TDD/SuperAdminKeywords.robot
Variables   /ebs/TDD/varfiles/providers.py
Variables   /ebs/TDD/varfiles/hl_musers.py
Variables   /ebs/TDD/varfiles/consumerlist.py
Variables   /ebs/TDD/varfiles/consumermail.py

*** Keywords ***
Testing kwargs
    [Arguments]  &{kwargs}

    ${data}=  Create Dictionary

    FOR  ${key}  ${value}  IN  &{kwargs}
        Set To Dictionary  ${data}   ${key}=${value}
    END

    Log  ${data}


*** Test Cases ***  
Testing

    ${CO_Number}=  FakerLibrary.Numerify  %#####
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${CO_Number}
    
    # ${NeededString}=    Fetch From Left    Raigarh(MH)    (

    # ${NeededString}=    Fetch From Left    Raigarh    (

*** Comment ***
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

    ${domresp}=  get_iscorp_subdomains  0
    Log  ${domresp}
    ${dlen}=  Get Length  ${domresp}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp[${d1}]['domain']}
    Set Test Variable  ${sub_dom}  ${domresp[${d1}]['subdomains']}
    
    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Suite Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
        Set Suite Variable  ${pkg_name}  ${licresp.json()[${pos}]['displayName']}
    END


