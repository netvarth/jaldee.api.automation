*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        servicelivetrack
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
${SERVICE1}         plumbing
${SERVICE2}         dishwashing
${SERVICE3}         cooking
${SrvName}          laundry


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
    RETURN  ${Provider_PH}

*** Test Case ***

JD-TC-EnableDisableServiceLiveTrack-1
    [Documentation]  Enable live tracking for a service
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+1082258
    Set Suite Variable   ${PUSERPH0}

*** Comments ***
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
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    
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

    # ${SERVICE1}=    FakerLibrary.word
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id1}

    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Enable Disbale Service Livetrack   ${s_id1}   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

JD-TC-EnableDisableServiceLiveTrack-2
    [Documentation]  Enable live tracking for more than one service
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${SERVICE2}=    FakerLibrary.word
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}   

    ${resp}=  Enable Disbale Service Livetrack   ${s_id2}   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service By Id  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    # ${SERVICE3}=    FakerLibrary.word
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${s_id3}  

    ${resp}=  Enable Disbale Service Livetrack   ${s_id3}   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service By Id  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}    ${s_id3}
    Should Be Equal As Strings   ${resp.json()[0]['livetrack']}   ${bool[1]}
    Should Be Equal As Strings   ${resp.json()[1]['id']}    ${s_id2}
    Should Be Equal As Strings   ${resp.json()[1]['livetrack']}   ${bool[1]}
    Should Be Equal As Strings   ${resp.json()[2]['id']}    ${s_id1}
    Should Be Equal As Strings   ${resp.json()[2]['livetrack']}   ${bool[1]}

JD-TC-EnableDisableServiceLiveTrack-3
    [Documentation]  Disable live tracking for a service

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Enable Disbale Service Livetrack   ${s_id1}   Disable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}



JD-TC-EnableDisableServiceLiveTrack-4
    [Documentation]  Disable live tracking for multiple services service

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Service By Id  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Enable Disbale Service Livetrack   ${s_id2}   Disable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service By Id  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

    ${resp}=  Get Service By Id  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Enable Disbale Service Livetrack   ${s_id3}   Disable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service By Id  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}    ${s_id3}
    Should Be Equal As Strings   ${resp.json()[0]['livetrack']}   ${bool[0]}
    Should Be Equal As Strings   ${resp.json()[1]['id']}    ${s_id2}
    Should Be Equal As Strings   ${resp.json()[1]['livetrack']}   ${bool[0]}
    Should Be Equal As Strings   ${resp.json()[2]['id']}    ${s_id1}
    Should Be Equal As Strings   ${resp.json()[2]['livetrack']}   ${bool[0]}

JD-TC-EnableDisableServiceLiveTrack-5
    [Documentation]  Disable Global live tracking when service live tracking is enabled
    ...     and check status of service live tracking

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Enable Disbale Service Livetrack   ${s_id1}   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Enable Disbale Service Livetrack   ${s_id2}   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service By Id  ${s_id2}
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

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}    ${s_id3}
    Should Be Equal As Strings   ${resp.json()[0]['livetrack']}   ${bool[0]}
    Should Be Equal As Strings   ${resp.json()[1]['id']}    ${s_id2}
    Should Be Equal As Strings   ${resp.json()[1]['livetrack']}   ${bool[0]}
    Should Be Equal As Strings   ${resp.json()[2]['id']}    ${s_id1}
    Should Be Equal As Strings   ${resp.json()[2]['livetrack']}   ${bool[0]}

JD-TC-EnableDisableServiceLiveTrack-6
    [Documentation]  Disable Global live tracking when service live tracking is enabled
    ...     and enable again and check status of service live tracking

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}    ${s_id3}
    Should Be Equal As Strings   ${resp.json()[0]['livetrack']}   ${bool[0]}
    Should Be Equal As Strings   ${resp.json()[1]['id']}    ${s_id2}
    Should Be Equal As Strings   ${resp.json()[1]['livetrack']}   ${bool[0]}
    Should Be Equal As Strings   ${resp.json()[2]['id']}    ${s_id1}
    Should Be Equal As Strings   ${resp.json()[2]['livetrack']}   ${bool[0]}

    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}    ${s_id3}
    Should Be Equal As Strings   ${resp.json()[0]['livetrack']}   ${bool[0]}
    Should Be Equal As Strings   ${resp.json()[1]['id']}    ${s_id2}
    Should Be Equal As Strings   ${resp.json()[1]['livetrack']}   ${bool[1]}
    Should Be Equal As Strings   ${resp.json()[2]['id']}    ${s_id1}
    Should Be Equal As Strings   ${resp.json()[2]['livetrack']}   ${bool[1]}


# JD-TC-EnableDisableServiceLiveTrack-7
#     [Documentation]  Enable and disable service live trackng for all licenses and check.

#     ${licresp}=   Get Licensable Packages
#     Log  ${licresp.json()}
#     Should Be Equal As Strings   ${licresp.status_code}   200
#     ${liclen}=  Get Length  ${licresp.json()}

#     FOR   ${i}  IN RANGE   ${liclen}
#         Set Test Variable  ${licId}  ${licresp.json()[${i}]['pkgId']}
#         Set Test Variable  ${lic_name}  ${licresp.json()[${i}]['displayName']}
#         ${puser}=   Get provider by license   ${licId}
#         Append To List   ${puser_list}  ${puser}
#     END

#     Log   ${puser_list}
#     ${user_len}=  Get Length  ${puser_list}

#     FOR  ${i}   IN RANGE   3

#         comment   Checking with license  
#         clear_service   ${puser_list[${i}]}
#         Log   ${licresp.json()[${i}]['displayName']}
#         ${resp}=   Encrypted Provider Login  ${puser_list[${i}]}  ${PASSWORD} 
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}   200

#         # ${resp}=  Enable Disbale Global Livetrack   Enable
#         # Log  ${resp.json()}
#         # Should Be Equal As Strings    ${resp.status_code}    422
#         # Should Be Equal As Strings    ${resp.json()}    ${EXCEEDS_LIMIT}

#         # ${resp}=  Get Account Settings
#         # Log  ${resp.json()}
#         # Should Be Equal As Strings    ${resp.status_code}    200
#         # Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

#         ${resp}=  Get Account Settings
#         Log  ${resp.json()}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         ${resp}=  Run Keyword If  ${resp.json()['livetrack']}==${bool[0]}   Enable Disbale Global Livetrack   ${toggle[0]}
#         Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
#         Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  422
#         Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.content}  ${EXCEEDS_LIMIT}
#         # ${SrvName}=    FakerLibrary.word
#         ${s_id}=  Create Sample Service  ${SrvName}
#         Set Suite Variable   ${s_id}

#         ${resp}=  Enable Disbale Service Livetrack   ${s_id}   Enable
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}    422

#         ${resp}=  Get Service By Id  ${s_id}
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}    200
#         Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

#         ${resp}=   ProviderLogout 
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}   200

#     END


#     FOR  ${i}   IN RANGE   3   ${user_len}

#         comment   Checking with license  
#         Log   ${licresp.json()[${i}]['displayName']}
#         ${resp}=   Encrypted Provider Login  ${puser_list[${i}]}  ${PASSWORD} 
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}   200

#         ${resp}=  Enable Disbale Global Livetrack   Enable
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}    200

#         ${resp}=  Get Account Settings
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}    200
#         Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

#         # ${SrvName}=    FakerLibrary.word
#         ${s_id}=  Create Sample Service  ${SrvName}
#         Set Suite Variable   ${s_id}

#         ${resp}=  Enable Disbale Service Livetrack   ${s_id}   Enable
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}    200

#         ${resp}=  Get Service By Id  ${s_id}
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}    200
#         Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

#         ${resp}=  Enable Disbale Service Livetrack   ${s_id}   Disable
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}    200

#         ${resp}=  Get Service By Id  ${s_id}
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}    200
#         Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

#         ${resp}=  Enable Disbale Global Livetrack   Disable
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}    200

#         ${resp}=  Get Account Settings
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}    200
#         Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

#         ${resp}=   ProviderLogout 
#         Log  ${resp.json()}
#         Should Be Equal As Strings    ${resp.status_code}   200

#     END

JD-TC-EnableDisableServiceLiveTrack-UH1
    [Documentation]  Enable service live tracking without Enabling Global live tracking

    clear_service   ${PUSERPH0}
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${SERVICE}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE}
    Set Suite Variable   ${s_id}   

    ${resp}=  Enable Disbale Global Livetrack   Disable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

    ${resp}=  Enable Disbale Service Livetrack   ${s_id}   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422

    ${resp}=  Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]} 


JD-TC-EnableDisableServiceLiveTrack-UH2
    [Documentation]  Disable service live tracking without Enabling Global live tracking

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Disbale Service Livetrack   ${s_id}   Disable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422

    ${resp}=  Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]} 

JD-TC-EnableDisableServiceLiveTrack-UH3
    [Documentation]  Disable service live tracking without Enabling it

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

    ${resp}=  Enable Disbale Service Livetrack   ${s_id}   Disable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422

    ${resp}=  Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]} 

JD-TC-EnableDisableServiceLiveTrack-UH4
    [Documentation]  Enable already enabled service live tracking
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[0]}

    ${resp}=  Enable Disbale Service Livetrack   ${s_id}   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]} 

    ${resp}=  Enable Disbale Service Livetrack   ${s_id}   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422

    ${resp}=  Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['livetrack']}   ${bool[1]}

JD-TC-EnableDisableServiceLiveTrack-UH5
    [Documentation]  Enable service live tracking without login

    ${resp}=  Enable Disbale Service Livetrack   ${s_id}   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419