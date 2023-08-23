*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        LiveTrack
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***

@{puser_list}

***Keywords***

Get provider by license
    [Arguments]   ${lic_id}
    
    ${resp}=   Get File    ${EXECDIR}/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE  ${length}
            
        ${Provider_PH}=  Set Variable  ${PUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${domain}=   Set Variable    ${resp.json()['sector']}
        ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=   Get Active License
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${pkg_id}=   Set Variable  ${resp.json()['accountLicense']['licPkgOrAddonId']}
        ${pkg_name}=   Set Variable  ${resp.json()['accountLicense']['name']}
	    # Run Keyword IF   ${resp.json()['accountLicense']['licPkgOrAddonId']} == ${lic_id}   AND   ${resp.json()['accountLicense']['name']} == ${lic_name}   Exit For Loop
        Exit For Loop IF  ${resp.json()['accountLicense']['licPkgOrAddonId']} == ${lic_id}

    END
    [Return]  ${Provider_PH}

*** Test Case ***

JD-TC-EnableDisableGlobalLiveTrack-1
    [Documentation]  Enable Global live tracking

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+1081
    Set Suite Variable   ${PUSERPH0}

*** comment ***
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${dom}=  Random Int   min=0  max=${dlen-1}
    Set Suite Variable  ${d1}  ${domresp.json()[${dom}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${dom}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Suite Variable  ${sd1}  ${domresp.json()[${dom}]['subDomains'][${sdom}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element  ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    true
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}081.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERPH0}

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

JD-TC-EnableDisableGlobalLiveTrack-2
    [Documentation]  Disable Global live tracking

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Enable Disbale Global Livetrack   Disable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}


JD-TC-EnableDisableGlobalLiveTrack-3
    [Documentation]  Disable Global live tracking when service live tracking is enabled
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_service   ${PUSERPH0}

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Enable Disbale Service Livetrack   ${s_id}   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Enable Disbale Global Livetrack   Disable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

JD-TC-EnableDisableGlobalLiveTrack-4
    [Documentation]  Enable and disable global live trackng for all licenses and check.

    ${licresp}=   Get Licensable Packages
    Log  ${licresp.json()}
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}

    # @{puser_list}=  []
    FOR   ${i}  IN RANGE   ${liclen}
        Set Test Variable  ${licId}  ${licresp.json()[${i}]['pkgId']}
        Set Test Variable  ${lic_name}  ${licresp.json()[${i}]['displayName']}
        ${puser}=   Get provider by license   ${licId}
        Append To List   ${puser_list}  ${puser}
    END

    Log   ${puser_list}
    ${user_len}=  Get Length  ${puser_list}

    comment   Checking with 1st license
    Log   ${licresp.json()[0]['displayName']}
    ${resp}=   Encrypted Provider Login  ${puser_list[0]}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings    ${resp.json()}    "${EXCEEDS_LIMIT}"

    ${resp}=   ProviderLogout 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment   Checking with 2nd license  
    Log   ${licresp.json()[1]['displayName']}
    ${resp}=   Encrypted Provider Login  ${puser_list[1]}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${EXCEEDS_LIMIT}

    ${resp}=   ProviderLogout 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment   Checking with 3rd license  
    Log   ${licresp.json()[2]['displayName']}
    ${resp}=   Encrypted Provider Login  ${puser_list[1]}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${EXCEEDS_LIMIT}

    ${resp}=   ProviderLogout 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    FOR  ${i}   IN RANGE   3   ${user_len}

        comment   Checking with license  
        Log   ${licresp.json()[${i}]['displayName']}
        ${resp}=   Encrypted Provider Login  ${puser_list[${i}]}  ${PASSWORD} 
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Enable Disbale Global Livetrack   Enable
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

        ${resp}=  Enable Disbale Global Livetrack   Disable
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

        ${resp}=   ProviderLogout 
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200

    END


JD-TC-EnableDisableGlobalLiveTrack-UH1
    [Documentation]  Enable global live tracking without login

    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-EnableDisableGlobalLiveTrack-UH2
    [Documentation]  Disable global live tracking without login

    ${resp}=  Enable Disbale Global Livetrack   Disable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-EnableDisableGlobalLiveTrack-UH3
    [Documentation]  Disable global live tracking without Enabling it

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

    ${resp}=  Enable Disbale Global Livetrack   Disable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

JD-TC-EnableDisableGlobalLiveTrack-UH4
    [Documentation]  Enable already enabled global live tracking

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}