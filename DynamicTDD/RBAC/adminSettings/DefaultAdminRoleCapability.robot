*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        RBAC
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***

${SERVICE1}     SERVICE1
${SERVICE2}     SERVICE2
${SERVICE3}     SERVICE3
${SERVICE4}     SERVICE4
${SERVICE5}     SERVICE5
${SERVICE6}     SERVICE6
@{service_duration}  10  20  30   40   50
@{Views}  self  all  customersOnly
@{emptylist}
@{list}  10  20  30   40   50
*** Test Cases ***

JD-TC-Default Admin Role Capability-1

    [Documentation]   Login a provider then enable main Rbac , verify default user role.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable Main RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableRbac']}  ${bool[1]}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Capabilities By Feature       ${rbac_feature[3]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Capa_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${Capa_name1}  ${resp.json()[0]['displayName']}
    Set Suite Variable  ${Capa_id2}    ${resp.json()[1]['id']}
    Set Suite Variable  ${Capa_name2}  ${resp.json()[1]['displayName']}
    Set Suite Variable  ${Capa_id3}    ${resp.json()[2]['id']}
    Set Suite Variable  ${Capa_name3}  ${resp.json()[2]['displayName']}
    Set Suite Variable  ${Capa_id4}    ${resp.json()[3]['id']}
    Set Suite Variable  ${Capa_name4}  ${resp.json()[3]['displayName']}
    Set Suite Variable  ${Capa_id5}    ${resp.json()[4]['id']}
    Set Suite Variable  ${Capa_name5}  ${resp.json()[4]['displayName']}
    Set Suite Variable  ${Capa_id6}    ${resp.json()[5]['id']}
    Set Suite Variable  ${Capa_name6}  ${resp.json()[5]['displayName']}
    Set Suite Variable  ${Capa_id7}    ${resp.json()[6]['id']}
    Set Suite Variable  ${Capa_name7}  ${resp.json()[6]['displayName']}
    Set Suite Variable  ${Capa_id21}    ${resp.json()[21]['id']}
    Set Suite Variable  ${Capa_name21}  ${resp.json()[21]['displayName']}
    Set Suite Variable  ${Capa_id24}    ${resp.json()[24]['id']}
    Set Suite Variable  ${Capa_name24}  ${resp.json()[24]['displayName']}

    ${resp}=  Get Default Roles With Capabilities  ${rbac_feature[3]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['adminSettingsRoles'][0]['feature']}    ${rbac_feature[3]}

JD-TC-Default Admin Role Capability-2

    [Documentation]   provider checking 'View account profile' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Default Admin Role Capability-3

    [Documentation]   provider checking 'Update account profile' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}
    Set Test Variable  ${firstname}  ${decrypted_data['firstName']}
    Set Test Variable  ${lastname}  ${decrypted_data['lastName']}
    Set Test Variable   ${domain}  ${decrypted_data['sector']}
    Set Test Variable   ${subdomain}  ${decrypted_data['subSector']}
    Set Suite Variable    ${username}    ${decrypted_data['userName']}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${number}

    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${name3}=  FakerLibrary.word
    ${emails1}=  Emails  ${name3}  Email  ${number}${P_Email}.${test_mail}  ${views}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Test Variable  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${b_loc}=  Create Dictionary  place=${city}   longitude=${longi}   lattitude=${latti}    googleMapUrl=${url}   pinCode=${postcode}  address=${address}
    ${emails}=  Create List  ${emails1}
    ${resp}=  Update Business Profile with kwargs   businessName=${bs}   shortName=${bs}   businessDesc=Description baseLocation=${b_loc}   emails=${emails}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${spec1}     ${resp.json()[0]['displayName']}   
    Set Test Variable    ${spec2}     ${resp.json()[1]['displayName']}   

    ${spec}=  Create List    ${spec1}   ${spec2}

    ${resp}=  Update Business Profile with kwargs  specialization=${spec}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Default Admin Role Capability-4

    [Documentation]   provider checking 'Create Location' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}

JD-TC-Default Admin Role Capability-5

    [Documentation]   provider checking 'Update Location' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${latti1}  ${longi1}  ${postcode1}  ${city1}  ${district}  ${state}  ${address1}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti1}  ${longi1}
    Set Suite Variable  ${latti1}
    Set Suite Variable  ${longi1}
    Set Suite Variable  ${postcode1}

    Set Suite Variable  ${tz}
    Set Suite Variable  ${address1}
    Set Suite Variable  ${city1}
    ${parking_type1}    Random Element     ['none','free','street','privatelot','valet','paid']
    Set Suite Variable  ${parking_type1}
    ${24hours1}    Random Element    ['True','False']
    Set Suite Variable  ${24hours1}
    ${resp}=  Update Location  ${city1}  ${longi1}  ${latti1}  www.${city1}.com  ${postcode1}  ${address1}  ${parking_type1}  ${24hours1}  ${lid} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  UpdateBaseLocation  ${lid}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Default Admin Role Capability-6

    [Documentation]   provider checking 'Get Location' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Location By Id   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Locations By UserId   ${userId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Default Admin Role Capability-7

    [Documentation]   provider checking 'Create User' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+300145
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${whpnum}=  Evaluate  ${PUSERNAME}+336245
    # ${tlgnum}=  Evaluate  ${PUSERNAME}+336345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${countryCodes[1]}  ${PUSERNAME_U1}    ${userType[0]}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}


JD-TC-Default Admin Role Capability-8

    [Documentation]   provider checking 'Update User' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name

    ${resp}=  Update User  ${u_id1}    ${countryCodes[1]}  ${PUSERNAME_U1}    ${userType[0]}   firstName=${firstname1}  lastName=${lastname1}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  EnableDisable User  ${u_id1}    ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Default Admin Role Capability-9

    [Documentation]   provider checking 'Get User' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Default Admin Role Capability-10

    [Documentation]   provider checking 'Create Customer Details' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PO_Number}    Generate random string    7    0123456789
    ${cons_num}    Convert To Integer  ${PO_Number}
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${cons_num}
    Set Suite Variable  ${CUSERPH} 
    ${firstname}=  FakerLibrary.first_name    
    ${lastname}=  FakerLibrary.last_name
     
    ${resp}=  AddCustomer  ${CUSERPH}   firstName=${firstname}   lastName=${lastname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

JD-TC-Default Admin Role Capability-11

    [Documentation]   provider checking 'Update Customer Details' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${resp}=  Update Customer Details  ${cid}  phoneNo=${CUSERPH}  countryCode=91  firstName=${firstname1}  lastName=${lastname1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Provider Consumer Profile Status    ${cid}    ${status[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Default Admin Role Capability-12

    [Documentation]   provider checking 'Get Customer Details' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    GetCustomer
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${Pcid}  ${resp.json()[0]['id']}

    ${resp}=  GetCustomer ById  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Default Admin Role Capability-13

    [Documentation]   provider checking 'Create Consumer Group' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${groupid}  ${resp.json()}

JD-TC-Default Admin Role Capability-14

    [Documentation]   provider checking 'Update Consumer Group' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName1}=   FakerLibrary.word
    Set Suite Variable  ${groupName1}
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Update Customer Group   ${groupid}  ${groupName1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Default Admin Role Capability-15

    [Documentation]   provider checking 'Get Consumer Group' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Default Admin Role Capability-16

    [Documentation]   provider checking 'Add or Remove Consumer Group' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${cust ids}=  Create List  ${Pcid}

    ${resp}=  Add Customers to Group   ${groupName1}   ${Pcid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Remove Customer from Group   ${groupName1}  ${Pcid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Default Admin Role Capability-17

    [Documentation]   provider checking 'Create Consumer Label' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END

    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${label_id}  ${resp.json()}

JD-TC-Default Admin Role Capability-18

    [Documentation]   provider checking 'View Consumer Label' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Default Admin Role Capability-18

    [Documentation]   provider checking 'Update Consumer Label' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Values2}=  FakerLibrary.Words  	nb=6
    Set Suite Variable  ${Values2}
    ${ValueSet}=  Create ValueSet For Label  ${Values2[0]}  ${Values2[1]}  ${Values2[2]}  ${Values2[3]}
    Set Suite Variable  ${ValueSet}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values2[0]}  ${Values2[4]}  ${Values2[2]}  ${Values2[5]}
    Set Suite Variable  ${NotificationSet}
    ${l_desc2}=  FakerLibrary.Sentence
    Set Suite Variable  ${l_desc2}
    ${l_name2}=  FakerLibrary.Words  nb=2
    Set Suite Variable  ${l_name2}
    ${resp}=  Update Label  ${label_id}  ${l_name2[0]}  ${l_name2[1]}  ${l_desc2}  ${ValueSet}  ${NotificationSet}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  EnableDisable Label   ${label_id}   ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Default Admin Role Capability-19

    [Documentation]   provider checking 'Apply Consumer Label' capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${l_name2[0]}  ${label_value}

    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200