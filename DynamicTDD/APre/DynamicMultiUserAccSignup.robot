*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Branch Signup
Library           Collections
Library           OperatingSystem
Library           String
Library           json
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py

*** Variables ***
${nods}  0
@{Views}  self  all  customersOnly
# ${defaultCount}  80
${PUSER}      ${PUSERNAME}


*** Test Cases ***

Remove Files
   
    # Remove File   ${EXECDIR}/TDD/varfiles/musers.py
    # Create File   ${EXECDIR}/TDD/varfiles/musers.py

    # Remove File   ${EXECDIR}/TDD/varfiles/hl_musers.py
    # Create File   ${EXECDIR}/TDD/varfiles/hl_musers.py

    Remove File   ${EXECDIR}/TDD/varfiles/providers.py
    Create File   ${EXECDIR}/TDD/varfiles/providers.py

    Remove File   ${EXECDIR}/TDD/varfiles/hl_providers.py
    Create File   ${EXECDIR}/TDD/varfiles/hl_providers.py

JD-TC-Branch_Signup-1
    [Documentation]    Create a provider with all valid attributes
    Set Suite Variable  ${US}  0
    Set Suite Variable  ${BR}  ${0}
    
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    FOR  ${index}  IN RANGE  ${len}
        ${sublen}=  Get Length  ${domresp.json()[${index}]['subDomains']}
        ${nods}=  Evaluate  ${nods}+${sublen}
    END

    # ${corp_resp}=   get_iscorp_subdomains  1
    # ${iscorpnods}=   Get Length  ${corp_resp}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()} 
    ${totnods}=   Evaluate  ${liclen}*${nods}
    # ${totiscorpnods}=   Evaluate  ${liclen}*${iscorpnods}


    # ${usercount}=  Set Variable If  ${provider_count}>${defaultCount}  ${provider_count}   ${defaultCount} 
    ${count}=  Set Variable If  ${provider_count}>${totnods}  ${provider_count}   ${totnods}
    Set Suite Variable  ${count}   
    #${newrange}=  Set Variable If  ${newlen}>${liclen}  ${newlen}   ${liclen}  
    # ${licresp}=   Get Licensable Packages
    # Should Be Equal As Strings   ${licresp.status_code}   200
    # ${liclen}=  Get Length  ${licresp.json()}  
    ${newlen}=  Evaluate  ${count}/(${liclen}*${nods})
    ${newlen}=  Set Variable If  ${newlen}<1  ${newlen+1}   ${newlen}
    Log   ${newlen}
    FOR  ${licindex}  IN RANGE  ${newlen}
        Exit For Loop If    '${US}' == '${count}'
        License Loop  ${liclen}  ${licresp}
    END
    Log Many  ${PUSER}  ${count}  ${US}

    ${count}=  Set Variable If  ${count}==${totnods}  ${totnods}   ${provider_count}
    Log  ${count}

    Log  \n${count} multiuser accounts signed up   console=yes

    ${PUSER}=  Evaluate  ${PUSER}-${count}
    
    sleep  01s
    FOR  ${no}  IN RANGE  ${count}
        ${PUSER}=  Evaluate  ${PUSER}+1
        ${resp}=  Encrypted Provider Login  ${PUSER}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${sub_domain}=  Set Variable  ${decrypted_data['subSector']}
        ${fname}=  Set Variable  ${decrypted_data['firstName']}
        ${lname}=  Set Variable  ${decrypted_data['lastName']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${account_id}  ${resp.json()['id']}

        ${resp}=  Get Waitlist Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[1]}

        ${resp}=  Get Features  ${sub_domain}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${service_name}  ${resp.json()['features']['defaultServices'][0]['service']}
        #Set Test Variable  ${service_amt}  ${resp.json()['features']['defaultServices'][0]['amount']}
        Set Test Variable  ${service_duration}  ${resp.json()['features']['defaultServices'][0]['duration']}
        Set Test Variable  ${service_status}  ${resp.json()['features']['defaultServices'][0]['status']}  

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword And Continue On Failure  Verify Response List   ${resp}  0  name=${service_name}  status=${service_status}  serviceDuration=${service_duration}
        #Verify Response List   ${resp}  0  totalAmount=${service_amt}

        ${resp}=    Get Locations
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Appointment Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
        Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    END

     
    
*** Keywords ***
SignUp Account
    [Arguments]    ${di}  ${d}  ${domresp}  ${pkgId}  ${pkg_name}
    ${sublen}=  Get Length  ${domresp.json()[${di}]['subDomains']}
    FOR  ${subindex}  IN RANGE  ${sublen} 
        Exit For Loop If    '${US}' == '${count}'
        Set Test Variable  ${sd}  ${domresp.json()[${di}]['subDomains'][${subindex}]['subDomain']}  
        ${is_corp}=  check_is_corp  ${sd}
        Log  ${is_corp}
        Continue For Loop If  '${is_corp}' == 'False'
        ${PUSER}=  Evaluate   ${PUSER}+1
        Set Suite Variable   ${PUSER}
        ${firstname}=  FakerLibrary.name
        ${lastname}=  FakerLibrary.last_name
        ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d}  ${sd}   ${PUSER}  ${pkgId}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    202
        ${jsessionynw_value}=   Get Cookie from Header  ${resp}
        ${resp}=  Account Activation   ${PUSER}  0  JSESSIONYNW=${jsessionynw_value}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Set Credential   ${PUSER}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSER}  JSESSIONYNW=${jsessionynw_value}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${highest_pkg}=  get_highest_license_pkg
        IF  '${pkgId}' == '${highest_pkg[0]}'
            Append To File  ${EXECDIR}/TDD/varfiles/hl_providers.py  HLPUSERNAME${BR}= ${PUSER}${\n}
            ${BR} =  Evaluate  ${BR}+1
            Set Suite Variable  ${BR}
        END
        # ${BR} =	Set Variable If	 '${pkgId}' == '${highest_pkg[0]}'	${BR+1}	 ${BR}
        # Set Suite Variable  ${BR}

        sleep  01s

        ${resp}=  Encrypted Provider Login   ${PUSER}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Suite Variable  ${pid}  ${decrypted_data['id']}

        Append To File  ${EXECDIR}/TDD/varfiles/providers.py  PUSERNAME${US}=${PUSER}${\n}
        Append To File  ${EXECDIR}/data/TDD_Logs/aprenumbers.txt  ${PUSER}${\n}
        
        Set Test Variable  ${email_id}  ${P_Email}${PUSER}.${test_mail}
        ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Business Profile
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  status=ACTIVE
        ${US} =  Evaluate  ${US}+1
        Set Suite Variable  ${US} 
        
        # ${DAY1}=  get_date
        # Set Suite Variable  ${DAY1}  ${DAY1}
        # ${list}=  Create List  1  2  3  4  5  6  7
        # Set Suite Variable  ${list}  ${list}
        # ${ph1}=  Evaluate   ${PUSER}+1000000000
        # ${ph2}=  Evaluate   ${PUSER}+2000000000
        # ${views}=  Evaluate  random.choice($Views)  random
        # ${name1}=  FakerLibrary.name
        # ${name2}=  FakerLibrary.name
        # ${name3}=  FakerLibrary.name
        # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
        # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
        # ${emails1}=  Emails  ${name3}  Email  ${P_Email}${US}.${test_mail}  ${views}
        # ${bs}=  FakerLibrary.bs
        # ${companySuffix}=  FakerLibrary.companySuffix
        # ${city}=   get_place
        # ${latti}=  get_latitude
        # ${longi}=  get_longitude
        # ${latti}  ${longi}=  get_lat_long
        # ${postcode}=  FakerLibrary.postcode
        # ${address}=  get_address
        # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
        # ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
        # Set Suite Variable  ${tz}
        # ${DAY1}=  get_date_by_timezone  ${tz}
        # ${Time}=  db.get_time_by_timezone   ${tz}
        # ${sTime}=  add_timezone_time  ${tz}  0  15  
        # Set Suite Variable   ${sTime}  ${sTime}
        # ${eTime}=  add_timezone_time  ${tz}  0  45  
        # Set Suite Variable   ${eTime}  ${eTime}

        #${resp}=  Create Business Profile  ${bs}  ${bs} Desc   ${companySuffix}  ${city}   ${longi}  ${latti}  www.${companySuffix}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}
        #Log  ${resp.json()}
        #Should Be Equal As Strings    ${resp.status_code}    200

        # ${resp}=  Update Business Profile with schedule  ${bs}  ${bs} Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${companySuffix}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200

        ${bs}=  FakerLibrary.company
        ${companySuffix}=  FakerLibrary.companySuffix
        ${parking}   Random Element   ${parkingType}
        ${24hours}    Random Element    ['True','False']
        ${desc}=   FakerLibrary.sentence
        ${url}=   FakerLibrary.url
        ${name3}=  FakerLibrary.word
        # ${emails1}=  Emails  ${name3}  Email  ${email_id}  ${views}
        ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
        ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
        Set Test Variable  ${tz}
        ${DAY1}=  db.get_date_by_timezone  ${tz}
        ${description}=  FakerLibrary.sentence

        ${b_loc}=  Create Dictionary  place=${city}   longitude=${longi}   lattitude=${latti}    googleMapUrl=${url}   pinCode=${postcode}  address=${address}  parkingType=${parking}  open24hours=${24hours}
        # ${emails}=  Create List  ${emails1}
        ${resp}=  Update Business Profile with kwargs   businessName=${bs}   businessUserName=${firstname}${SPACE}${lastname}   businessDesc=Description:${SPACE}${description}  shortName=${companySuffix}  baseLocation=${b_loc}   #emails=${emails}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Business Profile
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${account_id}  ${resp.json()['id']}
        Verify Response  ${resp}  businessName=${bs}  businessDesc=Description:${SPACE}${description}  shortName=${companySuffix}  status=ACTIVE  createdDate=${DAY1}  licence=${pkg_name}  verifyLevel=NONE  enableSearch=False  accountLinkedPhNo=${PUSER}  licensePkgID=${pkgId}  #accountType=INDEPENDENT_SP
        Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d}
        Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${city}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['address']}  ${address}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['pinCode']}  ${postcode}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${longi}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${latti}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  ${url}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  ${parking}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  ${24hours}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['status']}  ACTIVE
        
        ${fields}=   Get subDomain level Fields  ${d}  ${sd}
        Log  ${fields.json()}
        Should Be Equal As Strings    ${fields.status_code}   200

        ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

        ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get specializations Sub Domain  ${d}  ${sd}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${spec}=  get_Specializations  ${resp.json()}

        ${resp}=  Update Business Profile with kwargs  &{spec}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist Settings
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['enabledWaitlist']}==${bool[0]}   
            ${resp}=   Enable Waitlist
            Should Be Equal As Strings  ${resp.status_code}  200
        END

        ${resp}=   Get jaldeeIntegration Settings
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['onlinePresence']}==${bool[0]}
            ${resp}=  Set jaldeeIntegration Settings    ${bool[1]}  ${EMPTY}  ${EMPTY}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
        END

        ${resp}=   Get jaldeeIntegration Settings
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

        ${resp}=   Get Account Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['appointment']}   ${bool[0]}
        
        ${resp}=   Get Appointment Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['enableAppt']}==${bool[0]}   
            ${resp}=   Enable Disable Appointment   ${toggle[0]}
            Should Be Equal As Strings  ${resp.status_code}  200
        END

        ${resp}=   Get Account Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['appointment']}   ${bool[1]}

        enquiryStatus  ${account_id}
        leadStatus  ${account_id}

        ${resp}=    Get Locations
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword And Continue On Failure  Verify Response List   ${resp}  0  place=${city}  address=${address}  pinCode=${postcode}

    END

Domain Loop
    [Arguments]  ${pkgId}  ${pkg_name}
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    #Set Suite Variable  ${US}  0
    FOR  ${domindex}  IN RANGE  ${len}
        Exit For Loop If    '${US}' == '${count}' 
        Set Test Variable  ${d1}  ${resp.json()[${domindex}]['domain']}    
        SignUp Account  ${domindex}  ${d1}  ${resp}  ${pkgId}  ${pkg_name}
    END
License Loop
   [Arguments]  ${liclen}  ${licresp}
    FOR  ${licindex}  IN RANGE  ${liclen}
        Exit For Loop If    '${US}' == '${count}'
        Set Test Variable  ${pkgId}  ${licresp.json()[${licindex}]['pkgId']}
        Set Test Variable  ${pkg_name}  ${licresp.json()[${licindex}]['displayName']}
        Domain Loop  ${pkgId}  ${pkg_name}
    END