*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Account Settings
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           OperatingSystem
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***

JD-TC-GetAccountSettingsfromCache-1

    [Documentation]   Get business profile from cache by provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${acc_id}=  get_acc_id  ${PUSERNAME10}

    ${resp}=  Get Business Profile     
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${uid}      ${resp.json()['uniqueId']}   

    ${uniqueid}=  get_uid     ${PUSERNAME10}
    Set Suite Variable   ${uniqueid} 
   
    ${resp}=   Get Account Settings from Cache   ${uniqueid}   ${jsonNames[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetAccountSettingsfromCache-2

    [Documentation]   Get business profile from cache by provider login


    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Suite Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Suite Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+78577
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_A}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${acc_id}  ${decrypted_data['id']}

    # Set Test Variable  ${acc_id}  ${resp.json()['id']}

    ${uid}=  get_uid     ${PUSERNAME_A}
    Set Suite Variable   ${uid} 
   
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Suite Variable  ${PUSERNAME_A}

    ${pid}=  get_acc_id  ${PUSERNAME_A}
    Set Suite Variable  ${pid}
    
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME_A}${P_Email}.${test_mail}

    ${resp}=  Update Email   ${acc_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_A}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_A}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_A}.${test_mail}  ${views}
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
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  4  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}

    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Account Settings from Cache   ${uid}   ${jsonNames[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetAccountSettingsfromCache-3

    [Documentation]   Get virtualFields from cache by provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Account Settings from Cache   ${uid}   ${jsonNames[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetAccountSettingsfromCache-4

    [Documentation]   Get terminologies from cache by provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Account Settings from Cache   ${uid}   ${jsonNames[2]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetAccountSettingsfromCache-5

    [Documentation]   Get services from cache by provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Account Settings from Cache   ${uid}   ${jsonNames[3]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=   FakerLibrary.name
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Test Variable   ${s_id1}

    ${SERVICE2}=   FakerLibrary.name
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Test Variable   ${s_id2}

    sleep  5s
    # ${s3path}=  Set Variable  ${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['url']}
    # ${stringlist}=   Split String   ${s3path}  /  3
    # ${stringlist1}=   Split String   ${stringlist[2]}  .  1
    # ${stringlist2}=   Split String   ${stringlist[3]}  ?  1
    # ${path} 	${file} = 	Split String From Right   ${stringlist2[0]} 	/ 	1
    # ${output}=  Run  aws s3 ls s3://${stringlist1[0]}/${stringlist2[0]}
    # ${copy_output}=  Run  aws s3 cp /ebs/TDD/${file} s3://${stringlist1[0]}/${stringlist2[0]}
    # ${output}=  Run  aws s3 ls s3://${stringlist1[0]}/${stringlist2[0]}
    # ${resp1}=   Consumer Change Answer Status for Waitlist  ${account_id}  ${wid1}  ${fileid${j}}  ${lblname${j}}
    # ${resp1}=   Provider Change Answer Status for Waitlist  ${wid1}  ${fileid${j}}  ${lblname${j}}
    # Log  ${resp1.content}
    # Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get Account Settings from Cache   ${uid}   ${jsonNames[3]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetAccountSettingsfromCache-6

    [Documentation]   Get services from cache by provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  5s
    ${resp}=   Get Account Settings from Cache   ${uid}   ${jsonNames[3]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

*** Comments ***
JD-TC-GetAccountSettingsfromCache-4

    [Documentation]    Get donation services from cache by provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    ${min_don_amt1}=   Random Int   min=100   max=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Random Int   min=5000   max=10000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
    ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
    ${service_duration}=   Random Int   min=10   max=50
    ${total_amnt}=   Random Int   min=100   max=500
    ${total_amnt}=  Convert To Number  ${total_amnt}  1
    ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${don_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   Get Account Settings from Cache   ${uid}   ${jsonNames[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetAccountSettingsfromCache-5

    [Documentation]   Get locations from cache by provider login
