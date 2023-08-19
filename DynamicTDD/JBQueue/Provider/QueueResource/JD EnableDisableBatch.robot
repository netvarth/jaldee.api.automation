*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Batch
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
${prefix}                   serviceBatch
${suffix}                   serving


*** Test Case ***

JD-TC-EnableDisableBatch-1
    [Documentation]  Create queue and enable batch
    
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+1028
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}  AND  clear_customer  ${PUSERPH0}
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
    FOR  ${i}   IN RANGE   ${sdlen}
        ${sdom}=  Random Int   min=0  max=${sdlen-1}
        Set Suite Variable  ${sd1}  ${domresp.json()[${dom}]['subDomains'][${sdom}]['subDomain']}
        ${is_corp}=  check_is_corp  ${sd1}
        Exit For Loop IF   '${is_corp}' == 'False'
    END
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  "${resp.json()}"    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

***comment***
    ${DAY1}=  get_date
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
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}028.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_time  0  15
    Set Suite Variable   ${sTime}
    ${eTime}=  add_time   0  45
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[0]}

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  1s
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[1]}
    
    clear_queue  ${PUSERPH0}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 
    
    ${today}=  get_date
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${stime1}=  add_time  0  45
    ${etime1}=  add_time  1  0
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=4
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    # ${cid}=  get_id  ${CUSERNAME1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['batchId']}    1
    Should Be Equal As Strings  ${resp.json()['batchName']}    ${prefix}1${suffix}

JD-TC-EnableDisableBatch-2
    [Documentation]  Enable batch, add to waitlist, disable batch
    clear_queue  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 
    
    ${today}=  get_date
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${stime1}=  add_time  0  45
    ${etime1}=  add_time  1  0
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=4
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()[0]['id']}

    # ${cid}=  get_id  ${CUSERNAME1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['batchId']}    1
    Should Be Equal As Strings  ${resp.json()['batchName']}    ${prefix}1${suffix}

    ${resp}=  Disable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[0]}

JD-TC-EnableDisableBatch-5
    [Documentation]  Give batch name without suffix
    clear_queue  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 
    
    ${today}=  get_date
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${stime1}=  add_time  0  45
    ${etime1}=  add_time  1  0
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=4
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    # ${cid}=  get_id  ${CUSERNAME1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['batchId']}    1
    Should Be Equal As Strings  ${resp.json()['batchName']}    ${prefix}1

JD-TC-EnableDisableBatch-6
    [Documentation]  Give batch name without prefix
    clear_queue  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.firstname
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 
    
    ${today}=  get_date
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${stime1}=  add_time  0  45
    ${etime1}=  add_time  1  0
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=4
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${EMPTY}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    # ${cid}=  get_id  ${CUSERNAME1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['batchId']}    1
    Should Be Equal As Strings  ${resp.json()['batchName']}    1${suffix}

JD-TC-EnableDisableBatch-7
    [Documentation]  Enable batch without batch name
    clear_queue  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.lastname
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 
    
    ${today}=  get_date
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${stime1}=  add_time  0  45
    ${etime1}=  add_time  1  0
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=4
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    # ${cid}=  get_id  ${CUSERNAME1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['batchId']}    1
    Should Be Equal As Strings  ${resp.json()['batchName']}    1

    ${resp}=  Disable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-EnableDisableBatch-8
    [Documentation]  Enable batch for service in department
    # clear_queue  ${PUSERPH0}
    # clear_Department   ${PUSERPH0}
    # ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    # Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${resp}=    Get Locations
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_K}=  Evaluate  ${MUSERNAME}+423726
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_K}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_K}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_K}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${MUSERNAME_K}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_K}${\n}
    Set Suite Variable  ${MUSERNAME_K}
    
    ${acc_id}=  get_acc_id  ${MUSERNAME_K}
    Set Suite Variable  ${acc_id}

    # ${resp}=   Create Sample Location
    # Set Suite Variable    ${lid}    ${resp}  
    
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${MUSERNAME_K}+1000000000
    ${ph2}=  Evaluate  ${MUSERNAME_K}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}181.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  subtract_time  3  00
    Set Suite Variable  ${BsTime30}  ${sTime}
    ${eTime}=  add_time   2  30
    Set Suite Variable  ${BeTime30}  ${eTime}
    ${resp}=  Create Business Profile  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   02s

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[0]}
    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    
    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}


    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${did}  ${resp.json()}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service Department  ${P1SERVICE1}  ${desc}   5  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${did}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 
    
    ${today}=  get_date
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${stime1}=  add_time  0  45
    ${etime1}=  add_time  1  0
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=4
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    
    # ${cid}=  get_id  ${CUSERNAME1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['batchId']}    1
    Should Be Equal As Strings  ${resp.json()['batchName']}    1

    ${resp}=  Disable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Department  ${did}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-EnableDisableBatch-UH1
    [Documentation]  Enable batch with invalid queue id
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Waitlist Batch   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_NOT_FOUND}"

JD-TC-EnableDisableBatch-UH2
    [Documentation]  Enable batch without provider login

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-EnableDisableBatch-UH3
    [Documentation]  Enable batch with another provider login

    ${resp}=  Provider Login  ${PUSERNAME29}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-EnableDisableBatch-UH4
    [Documentation]  Disable batch when it is not enabled

    ${resp}=  Provider Login  ${MUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Disable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "already disabled"

JD-TC-EnableDisableBatch-UH5
    [Documentation]  Enable already enabled batch

    ${resp}=  Provider Login  ${MUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "already enabled"

*** comment ***



JD-TC-EnableDisableBatch-3
    [Documentation]  Add to waitlist, Enable batch
    clear_queue  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 
    
    ${today}=  get_date
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${stime1}=  add_time  0  45
    ${etime1}=  add_time  1  0
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=2
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}
    
    # ${cid1}=  get_id  ${CUSERNAME1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}   ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    # ${cid2}=  get_id  ${CUSERNAME2}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}   ${resp.json()[0]['id']}
    # ${cid3}=  get_id  ${CUSERNAME3}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}   ${cid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}   ${resp.json()[0]['id']}
    # ${cid4}=  get_id  ${CUSERNAME4}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid4}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}   ${cid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}

    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[1]}  
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[1]}  
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=2  waitlistStatus=${wl_status[1]}  
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=4  waitlistStatus=${wl_status[1]}  
    

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    ${resp}=  Get Waitlist Today  queue-eq=${p1_q1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[1]}  batchId=1   batchName=${prefix}1${suffix}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[1]}  batchId=1   batchName=${prefix}2${suffix}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=5  waitlistStatus=${wl_status[1]}  batchId=2   batchName=${prefix}3${suffix}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=5  waitlistStatus=${wl_status[1]}  batchId=2   batchName=${prefix}4${suffix}

    ${resp}=  Disable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[0]}

JD-TC-EnableDisableBatch-4
    [Documentation]  Add to waitlist, Enable batch for future waitlist
    clear_queue  ${PUSERPH0}
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   5   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${p1_s1}  ${resp.json()} 
    
    ${tomorrow}=  add_date  1
    ${today}=  get_date
    Set Suite Variable  ${today}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${stime1}=  add_time  0  45
    ${etime1}=  add_time  1  0
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  Random Int  min=2   max=2
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_q1}  ${resp.json()}
    
    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}
    
    # ${cid1}=  get_id  ${CUSERNAME1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${p1_s1}  ${p1_q1}  ${tomorrow}  ${desc}  ${bool[1]}   ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    # ${cid2}=  get_id  ${CUSERNAME2}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${p1_s1}  ${p1_q1}  ${tomorrow}  ${desc}  ${bool[1]}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}   ${resp.json()[0]['id']}
    
    # ${cid3}=  get_id  ${CUSERNAME3}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${p1_s1}  ${p1_q1}  ${tomorrow}  ${desc}  ${bool[1]}   ${cid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}   ${resp.json()[0]['id']}

    # ${cid4}=  get_id  ${CUSERNAME4}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid4}  ${p1_s1}  ${p1_q1}  ${tomorrow}  ${desc}  ${bool[1]}   ${cid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}

    ${resp}=  Enable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Batch Name   ${p1_q1}  ${prefix}  ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[1]}

    ${resp}=  Get Waitlist Future 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[1]}  batchId=1   batchName=${prefix}1${suffix}   date=${tomorrow}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[1]}  batchId=1   batchName=${prefix}2${suffix}   date=${tomorrow}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=5  waitlistStatus=${wl_status[1]}  batchId=2   batchName=${prefix}3${suffix}   date=${tomorrow}
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=5  waitlistStatus=${wl_status[1]}  batchId=2   batchName=${prefix}4${suffix}   date=${tomorrow}

    ${resp}=  Disable Waitlist Batch   ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()['batch']}    ${bool[0]}
