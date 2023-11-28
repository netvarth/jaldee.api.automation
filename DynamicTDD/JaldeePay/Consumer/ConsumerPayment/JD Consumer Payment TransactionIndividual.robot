*** Settings ***
Test Teardown     Delete All Sessions
Force Tags        Bill
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${digits}       0123456789
${service_duration}   2
${parallel}           1
${self}               0
@{provider_list}
${start}              140

*** Test Cases ***

JD-TC-Consumer-Payment-Transaction-Individual-1
    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment first then full payment
   
    # ${billable_providers}=    Billable Domain Providers   min=70   max=80
    # Log   ${billable_providers}
    # Set Suite Variable   ${billable_providers}
    # ${pro_len}=  Get Length   ${billable_providers}
    # Log  ${pro_len}
    # clear_location  ${PUSERPH1}
    # clear_service    ${PUSERPH1}
    # clear_queue     ${PUSERPH1}
    # clear_customer   ${PUSERPH1}

    # ${pid}=  get_acc_id  ${PUSERPH1}
    # Set Suite Variable  ${pid}

    # ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${DAY}
    # ${list}=  Create List  1  2  3  4  5  6  7

    ${PO_Number}    Generate random string    8    1234564789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH1}${\n}
    Set Suite Variable   ${PUSERPH1}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH1}   AND  clear_service  ${PUSERPH1}  AND  clear_Item    ${PUSERPH1}  AND   clear_Coupon   ${PUSERPH1}   AND  clear_Discount  ${PUSERPH1}  AND  clear_appt_schedule   ${PUSERPH1}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Test Variable   ${licid}
    
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ['Male', 'Female']
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH1}  ${licid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH1}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.content}    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH1}  ${PASSWORD}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH1}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH1}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.${test_mail}  ${views}
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

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  
    
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH1}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # ------------- Get general details and settings of the provider and update all needed settings
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}

    ${resp}=  Enable Waitlist
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${p1_lid}=  Create Sample Location
    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=300
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${pre_float}=  twodigitfloat  ${min_pre}
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot}   ${Tot1}

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Tot}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2} 
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot}  ${bool[0]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid2}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME6}
    Set Suite Variable   ${cid1}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    ${totalamt}=  twodigitfloat  ${totalamt}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre}
    ${balamount}=  Convert To Number  ${balamount}  2

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    sleep   02s
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Make payment Consumer Mock  ${min_pre}  ${bool[1]}  ${cwid}  ${pid}  ${purpose[0]}  ${cid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   02s

    ${resp}=   Get Payment Details By UUId   ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${id}   ${resp.json()[0]['id']} 

    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}

    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...    billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre}   totalTaxAmount=${tax}
    Should Be Equal As Numbers  ${resp.json()['netRate']}   ${totalamt} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${balamount}

    ${resp}=  Get Individual Payment Records   ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    Should Be Equal As Strings  ${resp.json()['amount']}   ${min_pre}
    Should Be Equal As Strings  ${resp.json()['paymentMode']}  Mock
    Should Be Equal As Strings  ${resp.json()['paymentRefId']}   ${payref}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}    ${cwid}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount}  ${purpose[1]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${balamount}  ${bool[1]}  ${cwid}  ${pid}  ${purpose[1]}  ${cid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   01s
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}   paymentStatus=${paymentStatus[2]}


JD-TC-Consumer-Payment-Transaction-Individual-2
    [Documentation]  Taking waitlist from consumer side and the consumer doing the billpayment 

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid2}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]} 

    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    ${totalamt}=  Convert To Number  ${totalamt}  2
    ${amt_float}=  twodigitfloat  ${totalamt} 

    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   

    # sleep  2s
    ${resp}=  Make payment Consumer Mock  ${pid}  ${amt_float}  ${purpose[0]}  ${wid1}  ${p1_sid2}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock   ${amt_float}  ${bool[1]}  ${wid1}  ${pid}  ${purpose[1]}   ${cid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   02s
    ${resp}=   Get Payment Details By UUId   ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${id1}   ${resp.json()[0]['id']} 

    Should Be Equal As Numbers  ${resp.json()[0]['amount']}   ${amt_float}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid1}

    ${resp}=  Get Bill By consumer  ${wid1}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[2]}   amountDue=0.0
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}   ${amt_float}
    
    ${resp}=  Get Individual Payment Records   ${id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${id1}
    Should Be Equal As Numbers  ${resp.json()['amount']}   ${amt_float}
    Should Be Equal As Strings  ${resp.json()['paymentMode']}  Mock
    Should Be Equal As Strings  ${resp.json()['paymentRefId']}   ${payref}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}    ${wid1}

    ${resp}=   Encrypted Provider Login   ${PUSERPH1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=  Get Waitlist By Id  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}
    
JD-TC-Consumer-Payment-Transaction-Individual-3
    [Documentation]  Taking waitlist from provider side and the consumer doing the billpayment

    ${resp}=  Encrypted Provider Login   ${PUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()}

    ${msg}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${p1_sid2}  ${p1_qid}  ${DAY}  ${msg}  ${bool[1]}  ${cid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${tax}=  Evaluate  ${Tot}*(${gstpercentage[3]}/100)
    ${tax}=  Convert To Number  ${tax}  2
    ${totalamount}=  Evaluate  ${Tot}+${tax}
    ${amt_float}=  twodigitfloat  ${totalamount}

    ${resp}=  Get Bill By UUId  ${wid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${uuid}   ${resp.json()['uuid']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Pcid2}  ${resp.json()['id']}
    # sleep  2s
    ${resp}=  Make payment Consumer Mock  ${pid}  ${amt_float}  ${purpose[1]}  ${wid2}  ${p1_sid2}  ${bool[0]}   ${bool[1]}  ${Pcid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock   ${amt_float}  ${bool[1]}  ${wid2}  ${pid}  ${purpose[1]}   ${cid2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
    sleep   02s
    ${resp}=   Get Payment Details By UUId   ${wid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${id2}   ${resp.json()[0]['id']} 

    Should Be Equal As Numbers  ${resp.json()[0]['amount']}   ${amt_float}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid2}

    ${resp}=  Get Bill By consumer  ${wid2}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid2}  netTotal=${Tot}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  
    ...   billPaymentStatus=${paymentStatus[2]}   amountDue=0.0    totalTaxAmount=${tax}
    Should Be Equal As Numbers  ${resp.json()['netRate']}   ${amt_float} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}   ${amt_float}
    
    ${resp}=  Get Individual Payment Records   ${id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${id2}
    Should Be Equal As Numbers  ${resp.json()['amount']}   ${amt_float}
    Should Be Equal As Strings  ${resp.json()['paymentMode']}  Mock
    Should Be Equal As Strings  ${resp.json()['paymentRefId']}   ${payref}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}    ${wid2}

JD-TC-Consumer-Payment-Transaction-Individual-4

    [Documentation]  provider takes waitlist and accept payment then consumer get details
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email2}  ${firstname}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME4}  ${EMPTY}
    Set Suite Variable  ${cid}  ${resp.json()}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_sid2}  ${p1_qid}  ${DAY}  ${msg}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${tax}=  Evaluate  ${Tot}*(${gstpercentage[3]}/100)
    ${tax}=  Convert To Number  ${tax}  2
    ${amount}=  Evaluate  ${Tot}+${tax}
    ${amt_float}=  twodigitfloat  ${amount}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=${Tot}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}   
    ...   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0   taxableTotal=${Tot}  totalTaxAmount=${tax}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${amt_float} 
    Should Be Equal As Numbers  ${resp.json()['netRate']}   ${amt_float}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${p1_sid2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${P1SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstpercentage[3]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${Tot}
    Should Be Equal As Numbers  ${resp.json()['service'][0]['netRate']}  ${Tot}

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  ${amt_float}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}  ${amt_float}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment Details By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${id3}   ${resp.json()[0]['id']} 
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}  ${amt_float}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}   

    ${resp}=  Get Individual Payment Records   ${id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${id3}
    Should Be Equal As Numbers  ${resp.json()['amount']}   ${amt_float}
    Should Be Equal As Strings  ${resp.json()['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}    ${wid}


JD-TC-Consumer-Payment-Transaction-Individual-UH1

    [Documentation]   Get transaction details without login
    ${resp}=  Get Individual Payment Records   ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-Consumer-Payment-Transaction-Individual-UH2

    [Documentation]  get transaction details with invalid id
    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Individual Payment Records   0000
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "Invalid Id"

JD-TC-Consumer-Payment-Transaction-Individual-UH3

    [Documentation]   Another consumer try to get transaction details 
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Individual Payment Records   ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

JD-TC-Consumer-Payment-Transaction-Individual-UH4

    [Documentation]  Provider try to access transaction details 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Individual Payment Records   ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"
