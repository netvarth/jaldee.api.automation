*** Settings ***
Test Teardown     Delete All Sessions
Force Tags        Bill
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
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
${jcoupon1}   CouponMul00
${cc}                               +91
${withspl}                          @#!

*** Test Cases ***

JD-TC-Payment By Consumer-1

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment  first then full payment

    ${PO_Number}    Generate random string    8    123463789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH2}${\n}
    Set Suite Variable   ${PUSERPH2}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH2}   AND  clear_service  ${PUSERPH2}  AND  clear_Item    ${PUSERPH2}  AND   clear_Coupon   ${PUSERPH2}   AND  clear_Discount  ${PUSERPH2}  AND  clear_appt_schedule   ${PUSERPH2}
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
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH2}  ${licid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH2}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.content}    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH2}  ${PASSWORD}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   ProviderLogin  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${DAY}=  get_date
    Set Suite Variable  ${DAY}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH2}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH2}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.${test_mail}  ${views}
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

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH2}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # ------------- Get general details and settings of the provider and update all needed settings
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}

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
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${p1_lid}=  Create Sample Location

    ${min_pre1}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot1}  ${bool[0]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid2}  ${resp.json()}


    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME15}
    Set Suite Variable   ${cid1}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  twodigitfloat  ${totalamt}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    ${balamount}=  twodigitfloat  ${balamount}  

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  ProviderLogin  ${PUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre1}    totalTaxAmount=${tax}
    Should Be Equal As Numbers  ${resp.json()['netRate']}   ${totalamt} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${balamount} 

    sleep   1s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    
    sleep  2s
    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount}  ${purpose[1]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   ProviderLogin   ${PUSERPH2}  ${PASSWORD} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   01s
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}    paymentStatus=${paymentStatus[2]}


JD-TC-Payment By Consumer-2
    [Documentation]  Taking waitlist from consumer side and check prepay amount while checkin more than one person
    
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+1045733
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH1}${\n}
    Set Suite Variable   ${PUSERPH1}
    
    ${max_party}=  get_maxpartysize_subdomain
    Log    ${max_party}
    Set Suite Variable  ${d1}  ${max_party['domain']}
    Set Suite Variable  ${sd1}  ${max_party['subdomain']}

    ${pkg_id}=   get_highest_license_pkg

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH1}    ${pkg_id[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERPH1}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERPH1}  ${PASSWORD}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   ProviderLogin  ${PUSERPH1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${sTime}=  db.get_time
    ${eTime}=  add_time   4  15
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${lid}  ${resp.json()['baseLocation']['id']}

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH1}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Waitlist
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

   
  
    ${pid1}=  get_acc_id  ${PUSERPH1}
    Set Suite Variable  ${pid1}

    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${bankid2}   ${combined_json}=  Create Sample Payment Profile
   
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid1}

    # Set Test Variable  ${id}  ${payment_profile.json()['paymentProfiles']['profiles'][0]['id']}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Update Destination Bank  ${paymentprofileid[0]}  ${bool[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profiles  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bankid2}   ${pid1}  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${businessFilingStatus[1]}  ${accountType[1]}  ${EMPTY}  ${EMPTY}   
    ...   razorpayMerchantId=rzp_test_tD0hiOsaNEJfpk   razorpayMerchantKey=anvXiqqxugTK3JBOlBNTONEY   razorpayWebhookMerchantKey=abcd              
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=   Get Bank Info By Id   ${bankid2}  ${pid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p4_lid}  ${resp.json()[0]['id']} 

    ${prepay}=   Random Int   min=49   max=50
    ${Tot}=   Random Int   min=499   max=500
    ${prepay1}=  Convert To Number  ${prepay}  1
    Set Suite Variable   ${prepay}   ${prepay1}
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Test Variable   ${Tot}   ${Tot1}
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${prepay}  ${Tot}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p4_sid1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p4_lid}  ${p4_sid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p4_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME4}
    Set Suite Variable   ${cid1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cid1for}   ${resp.json()}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${p4_qid}  ${DAY}  ${p4_sid1}  ${msg}  ${bool[0]}  ${cid1for}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    Set Test Variable  ${cwidfam}  ${wid[1]} 

    ${totcharge}=  Evaluate  ${Tot}*2
    ${tax1}=  Evaluate  ${totcharge}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${amount}=   Evaluate  ${prepay}*2
    ${amount}=  Convert To Number  ${amount}  1
    ${amt_float}=  twodigitfloat  ${amount}
    ${balamount}=  Evaluate  (${totcharge}+${tax})-${amount}
    ${balamount1}=  twodigitfloat  ${balamount} 

    ${resp}=  Make payment Consumer Mock  ${pid1}  ${amount}  ${purpose[0]}  ${cwid}  ${p4_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    sleep   02s

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}

    ${resp}=  Make payment Consumer Mock  ${pid1}  ${balamount}  ${purpose[1]}  ${cwid}  ${p4_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   03s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}

    ${resp}=   ProviderLogin  ${PUSERPH1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

    ${resp}=  Get Waitlist By Id  ${cwidfam}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

JD-TC-Payment By Consumer-3

    [Documentation]  Taking waitlist and prepay full amount and  get bill
   
    clear_location  ${PUSERPH2}
    clear_service    ${PUSERPH2}
    clear_queue     ${PUSERPH2}
    ${pid}=  get_acc_id  ${PUSERPH2}
    Set Suite Variable  ${pid}

    ${resp}=  Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${p1_lid}=  Create Sample Location
    ${resp}=  Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_lid}  ${resp.json()[0]['id']} 

    ${min_pre}=   Random Int   min=49   max=50
    ${Tot}=   Random Int   min=499   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable   ${min_pre}
    ${pre_float}=  twodigitfloat  ${min_pre}
    Set Suite Variable   ${pre_float}  
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot}   ${Tot1}
    ${Tot_float}=  twodigitfloat  ${Tot}
    Set Suite Variable   ${Tot_float}

    ${P1SERVICE1}   ${P1SERVICE2}   ${P1SERVICE3}=  FakerLibrary.words  nb=3
    Set Suite Variable    ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Tot}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_sid1}  ${resp.json()}

    Set Suite Variable   ${P1SERVICE2} 
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot}  ${bool[0]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_sid2}  ${resp.json()}

    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot}  ${bool[0]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_sid3}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p2_lid}  ${p2_sid1}  ${p2_sid2}  ${p2_sid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()['id']}

    # ${cid2}=  get_id  ${CUSERNAME16}
    # Set Suite Variable   ${cid2}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p2_qid}  ${DAY}  ${p2_sid1}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    Set Suite Variable    ${tax}
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    ${amt_float}=  twodigitfloat  ${totalamt}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${totalamt}  ${purpose[0]}  ${cwid}  ${p2_sid1}  ${bool[0]}   ${bool[1]}  ${cid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${PAYMENT_AMOUNT_IS_NOT_MATCHED}
    # Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    # Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    # ${resp}=  ProviderLogin  ${PUSERPH2}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
    # sleep   02s

    # ${resp}=   Get Payment Details By UUId   ${cwid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${totalamt}
    # Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}

    # Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    # Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${totalamt}
    # Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    # Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}

    # ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${totalamt}  amountDue=0.0  taxableTotal=${Tot}  totalTaxAmount=${tax}

    # sleep   03s
    # ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}     waitlistStatus=${wl_status[0]}
    # # ...   paymentStatus=${paymentStatus[2]} 

    # ${resp}=   ProviderLogin  ${PUSERPH2}  ${PASSWORD} 
    # Should Be Equal As Strings    ${resp.status_code}   200
   
    # ${resp}=  Get Waitlist By Id  ${cwid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

JD-TC-Payment By Consumer-4

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment  first then doing full payment twice.
   
    clear_location  ${PUSERPH2}
    clear_service    ${PUSERPH2}
    clear_queue     ${PUSERPH2}
    clear_customer   ${PUSERPH2}

    ${pid}=  get_acc_id  ${PUSERPH2}
    Set Test Variable  ${pid}

    ${resp}=  Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY}=  get_date
    Set Test Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Test Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Test Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Test Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Test Variable   ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot1}  ${bool[0]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_sid2}  ${resp.json()}


    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()['id']}
    

    # ${cid1}=  get_id  ${CUSERNAME15}
    # Set Test Variable   ${cid1}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  twodigitfloat  ${totalamt}
    # ${totalamt}=  Round Val  ${totalamt}  1
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    ${balamount}=  Round Val  ${balamount}  2
    ${balamount}=  twodigitfloat  ${balamount}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  ProviderLogin  ${PUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre1}   totalTaxAmount=${tax}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${balamount}

    sleep   2s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount}  ${purpose[1]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogin   ${PUSERPH2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   01s
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}    paymentStatus=${paymentStatus[2]}

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}     waitlistStatus=${wl_status[0]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount}  ${purpose[1]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"       "${PAYMENT_ALREADY_PROCESSED}"
   
JD-TC-Payment By Consumer-5
    [Documentation]  Completeing a payment after a failed payment.
   
    clear_location  ${PUSERPH2}
    clear_service    ${PUSERPH2}
    clear_queue     ${PUSERPH2}
    clear_customer   ${PUSERPH2}

    ${pid}=  get_acc_id  ${PUSERPH2}
    Set Test Variable  ${pid}

    ${resp}=  Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY}=  get_date
    Set Test Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Test Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Test Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Test Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Test Variable   ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot1}  ${bool[0]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_sid2}  ${resp.json()}


    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME15}
    Set Test Variable   ${cid1}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    ${balamount}=  twodigitfloat  ${balamount}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  ProviderLogin  ${PUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre1}     totalTaxAmount=${tax}
    Should Be Equal As Numbers  ${resp.json()['netRate']}   ${totalamt} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${balamount} 

    sleep   1s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    
    sleep  2s
    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount}  ${purpose[1]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[0]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogin   ${PUSERPH2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   01s
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}    paymentStatus=${paymentStatus[1]}

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount}  ${purpose[1]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}     waitlistStatus=${wl_status[0]}

    ${resp}=   ProviderLogin   ${PUSERPH2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   01s
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}    paymentStatus=${paymentStatus[2]}

JD-TC-Payment By Consumer-6
    [Documentation]  Taking waitlist after a failed payment then prepay full amount and  get bill
   
    clear_location  ${PUSERNAME117}
    clear_service    ${PUSERNAME117}
    clear_queue     ${PUSERNAME117}
    ${pid11}=  get_acc_id  ${PUSERNAME117}
    Set Suite Variable  ${pid11}

    ${resp}=  Provider Login  ${PUSERNAME117}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY}=  get_date
    Set Test Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p1_lid}=  Create Sample Location
    ${resp}=  Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p2_lid}  ${resp.json()[0]['id']} 

    ${min_pre}=   Random Int   min=49   max=50
    ${Tot}=   Random Int   min=499   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Test Variable   ${min_pre}
    ${pre_float}=  twodigitfloat  ${min_pre}
    Set Test Variable   ${pre_float}  
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Total1}   ${Tot1}
    ${Tot_float}=  twodigitfloat  ${Tot}
    Set Test Variable   ${Tot_float}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable    ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Tot}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Test Variable   ${P1SERVICE2} 
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot}  ${bool[0]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_sid2}  ${resp.json()}

    ${P1SERVICE3}=    FakerLibrary.word
    Set Test Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot}  ${bool[0]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_sid3}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p2_lid}  ${p2_sid1}  ${p2_sid2}  ${p2_sid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p2_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    # ${cid2}=  get_id  ${CUSERNAME16}
    # Set Test Variable   ${cid2}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid11}  ${p2_qid}  ${DAY}  ${p2_sid2}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    Set Test Variable    ${tax}
    ${totalamt}=  Evaluate  ${Tot}+${tax}
    ${amt_float}=  twodigitfloat  ${totalamt}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid11}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[0]}

    ${resp}=  Make payment Consumer Mock  ${pid11}  ${totalamt}  ${purpose[1]}  ${cwid}  ${p2_sid2}  ${bool[0]}   ${bool[0]}  ${cid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}
 

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid11}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[0]}
    
    ${resp}=  Make payment Consumer Mock  ${pid11}  ${totalamt}  ${purpose[1]}  ${cwid}  ${p2_sid2}  ${bool[0]}   ${bool[1]}  ${cid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  ProviderLogin  ${PUSERNAME117}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Payment Details By UUId   ${cwid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${totalamt}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid11}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}

    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${totalamt}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid11}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}

    sleep   03s

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid11}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Total1}  billStatus=${billStatus[0]}    netRate=${totalamt}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${totalamt}  amountDue=0.0  taxableTotal=${Total1}  totalTaxAmount=${tax}
    # billViewStatus=${billViewStatus[0]}
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid11}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    waitlistStatus=${wl_status[0]}
    # ...   paymentStatus=${paymentStatus[2]} 

    ${resp}=   ProviderLogin  ${PUSERNAME117}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

JD-TC-Payment By Consumer-UH1
    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment twice.
   
    clear_location  ${PUSERNAME210}
    clear_service    ${PUSERNAME210}
    clear_queue     ${PUSERNAME210}
    clear_customer   ${PUSERNAME210}

    ${pid}=  get_acc_id  ${PUSERNAME210}
    Set Test Variable  ${pid}

    ${resp}=  Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    ${Tot1}=  Convert To Number  ${Tot}  1  

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_sid1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME15}
    Set Test Variable   ${cid1}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"       "${PAYMENT_ALREADY_PROCESSED}"
    
JD-TC-Payment By Consumer-UH2

    [Documentation]  Taking appointment from consumer side and the consumer doing prepayment twice.


    ${resp}=  Provider Login  ${PUSERNAME211}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_location  ${PUSERNAME211}
    clear_service    ${PUSERNAME211}
    clear_queue     ${PUSERNAME211}
    clear_customer   ${PUSERNAME211}

    ${pid}=  get_acc_id  ${PUSERNAME211}
    Set Test Variable  ${pid}

    ${DAY}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
   
    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    ${Tot1}=  Convert To Number  ${Tot}  1 

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_sid1}  ${resp.json()}

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}      ${parallel}    ${p1_lid}  ${duration}  ${bool[1]}  ${p1_sid1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME15}
    Set Test Variable   ${cid1}

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_sid1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    
    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   apptStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${apptid1}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${apptid1}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"       "${PAYMENT_ALREADY_PROCESSED}"
    

JD-TC-Payment By Consumer-UH3
   [Documentation]   Taking waitlist from consumer side and pay less amount in the final pay(bill payment)
    
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid7}=  get_id  ${CUSERNAME7}
    Set Suite Variable   ${cid7}

    ${cnote}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid11}  ${p2_qid}  ${DAY}  ${p2_sid1}  ${cnote}  ${bool[0]}   ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${min_pre}  ${resp.json()['_prepaymentAmount']}

    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${widc}  ${wid[0]} 
    
    ${tax}=  Evaluate  ${Tot}*(${gstpercentage[3]}/100)
    ${netRate}=  Evaluate  ${Tot}+${tax}
    ${balamount1}=  Evaluate  ${netRate}-${min_pre}
    ${balamount}=  Convert To Number  ${balamount1}  1
    ${amountpaid}=   Random Int   min=51   max=99
    ${amountpaid}=  Convert To Number  ${amountpaid}  1
    ${totalpaid}=   Evaluate  ${amountpaid}+${min_pre}
    ${totalpaid}=  Convert To Number  ${totalpaid}  1
    ${amt_float}=  twodigitfloat  ${amountpaid}
    ${amountdue}=  Evaluate  ${balamount1}-${amountpaid}
   
    ${resp}=  Make payment Consumer Mock  ${pid11}  ${min_pre}  ${purpose[0]}  ${widc}  ${p2_sid1}  ${bool[0]}   ${bool[1]}  ${cid7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   02s

    ${resp}=  Get consumer Waitlist By Id  ${widc}  ${pid11}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    
    ${resp}=  Make payment Consumer Mock  ${pid11}  ${amountpaid}  ${purpose[1]}  ${widc}  ${p2_sid1}  ${bool[0]}   ${bool[1]}  ${cid7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${PAYMENT_AMOUNT_IS_NOT_MATCHED}
    # Should Be Equal As Strings  "${resp.json()}"  "${AMOUNT_IS_LESS}"
    
JD-TC-Payment By Consumer-UH4
   [Documentation]   prepay full amount for a non taxable service and try to settle future chech-ins bill

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid8}=  get_id  ${CUSERNAME8}
    Set Suite Variable   ${cid8}

    ${DAY2}=  add_date  4
    ${cnote}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid11}  ${p2_qid}  ${DAY2}  ${p2_sid3}  ${cnote}  ${bool[0]}   ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${widc}  ${wid[0]} 
   
    ${resp}=  Make payment Consumer Mock  ${pid11}  ${Total1}  ${purpose[0]}  ${widc}  ${p2_sid3}  ${bool[0]}   ${bool[1]}  ${cid8}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   02s
    ${resp}=  Get consumer Waitlist By Id  ${widc}  ${pid11}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}

    ${resp}=   ProviderLogin  ${PUSERNAME117}  ${PASSWORD} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Bill By UUId  ${widc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Settl Bill  ${widc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${FUTURE_BILL_CANT_SETTLE}"
    
JD-TC-Payment By Consumer-UH5
   [Documentation]   Taking waitlist from provider side and pay an invalid amount for the bill(high amout)

    ${resp}=   ProviderLogin   ${PUSERNAME117}  ${PASSWORD} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()[0]['id']}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${p2_sid3}  ${p2_qid}  ${DAY}  ${msg}  ${bool[1]}  ${cid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]} 

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   netTotal=${Total1}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Pcid2}  ${resp.json()['id']}

    ${HighTotal}=   Random Int   min=600   max=700
    ${HighTotal1}=  Convert To Number  ${HighTotal}  1 
    Set Test Variable   ${HighTotal}   ${HighTotal1}

    ${resp}=  Make payment Consumer Mock  ${pid11}  ${HighTotal}  ${purpose[1]}  ${wid}  ${p2_sid3}  ${bool[0]}   ${bool[1]}  ${Pcid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${PAYMENT_AMOUNT_IS_NOT_MATCHED}
    # Should Be Equal As Strings  "${resp.json()}"  "${AMOUNT_IS_HIGH}"  

JD-TC-Payment By Consumer-UH6
   [Documentation]   Taking waitlist from provider side and pay less amount for the bill
    
    ${resp}=   ProviderLogin   ${PUSERNAME117}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${DAY2}=  add_date  3
    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${p2_sid3}  ${p2_qid}  ${DAY2}  ${msg}  ${bool[1]}  ${cid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}    

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   netTotal=${Total1}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${LowTotal}=   Random Int   min=100   max=200
    ${LowTotal1}=  Convert To Number  ${LowTotal}  1 
    Set Test Variable   ${LowTotal}   ${LowTotal1}

    ${resp}=  Make payment Consumer Mock  ${pid11}  ${LowTotal}  ${purpose[1]}  ${wid}  ${p2_sid3}  ${bool[0]}   ${bool[1]}  ${Pcid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${PAYMENT_AMOUNT_IS_NOT_MATCHED}
    # Should Be Equal As Strings  "${resp.json()}"    "${AMOUNT_IS_LESS}" 

JD-TC-Payment By Consumer-UH7
   [Documentation]   payment consumer to provider with invalid uuid

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${invalid_uuid}=  Random Int   min=000000000000   max=999999999999
    ${amount}=   Random Int   min=100   max=700
    ${resp}=  Make payment Consumer Mock  ${pid}  ${amount}  ${purpose[0]}  ${invalid_uuid}  ${p2_sid3}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-Payment By Consumer-UH8
   [Documentation]    payment consumer to provider, url using provider

   ${resp}=   ProviderLogin   ${PUSERNAME210}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${amount}=   Random Int   min=100   max=700
    ${resp}=  Make payment Consumer Mock  ${pid11}  ${amount}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${PAYMENT_AMOUNT_IS_NOT_MATCHED}"   	

JD-TC-Payment By Consumer-UH9
    [Documentation]  Taking waitlist from consumer side and  prepay less amount while checkin more than one person

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid3}=  get_id  ${CUSERNAME8}
    Set Suite Variable   ${cid3}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cid1for}   ${resp.json()}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${p4_qid}  ${DAY}  ${p4_sid1}  ${msg}  ${bool[0]}  ${cid1for}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    Set Test Variable  ${cwidfam}  ${wid[1]} 
    
    ${resp}=  Make payment Consumer Mock  ${pid1}  ${prepay}  ${purpose[0]}  ${cwid}  ${p4_sid1}  ${bool[0]}   ${bool[1]}  ${cid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${PAYMENT_AMOUNT_IS_NOT_MATCHED}
    # Should Be Equal As Strings  "${resp.json()}"     "${MINIMUM_PREPAYMENT_AMOUNT_SHOULD_BE_PROVIDED}"
    
    # ${resp}=  Provider Login  ${PUSERPH1}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # sleep  2s
    # ${resp}=  Get Waitlist By Id  ${cwid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  waitlistStatus=${wl_status[3]}

JD-TC-Payment By Consumer-UH10
   [Documentation]   Taking waitlist from consumer side and pay prepayment in provider side  by cash

    ${resp}=  Provider Login  ${PUSERNAME117}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service By Id  ${p2_sid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${total}  ${resp.json()['totalAmount']}

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid9}=  get_id  ${CUSERNAME9}
    Set Suite Variable   ${cid9}

    ${cnote}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid11}  ${p2_qid}  ${DAY}  ${p2_sid1}  ${cnote}  ${bool[0]}   ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid9}  ${wid[0]} 

    ${tax1}=  Evaluate  ${total}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${total}+${tax}
    ${amountdue}=  Evaluate  ${total}-${min_pre}
   
    ${resp}=  Provider Login  ${PUSERNAME117}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${wid9}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid9}  netTotal=${Total1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${totalamt}  taxableTotal=${Total1}  totalTaxAmount=${tax}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${p2_sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${P1SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstpercentage[3]}
    Should Be Equal As Numbers  ${resp.json()['service'][0]['price']}  ${total}
    Should Be Equal As Numbers  ${resp.json()['service'][0]['netRate']}  ${total}

    ${resp}=  Accept Payment  ${wid9}  ${payment_modes[0]}  ${min_pre}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION_TO_DO}"


JD-TC-Payment By Consumer-UH11

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment(less amount).
   
    ${billable_providers}=     Billable Domain Providers    min=180   max=190
    Log   ${billable_providers}
    Set Suite Variable   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    Log  ${pro_len}
    clear_location  ${PUSERPH2}
    clear_service    ${PUSERPH2}
    clear_queue     ${PUSERPH2}
    clear_customer   ${PUSERPH2}

    ${pid}=  get_acc_id  ${PUSERPH2}
    Set Suite Variable  ${pid}

    ${resp}=  Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
   
    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot1}  ${bool[0]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid2}  ${resp.json()}


    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME15}
    Set Suite Variable   ${cid1}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    # ${balamount1}=  Convert To Number  ${balamount}  1

    ${min_amount}=  Evaluate  ${min_pre1} - 10
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_amount}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${PAYMENT_AMOUNT_IS_NOT_MATCHED}

    # ${resp}=  Provider Login  ${PUSERPH2}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # sleep  02s
    # ${resp}=  Get Waitlist By Id  ${cwid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

JD-TC-Payment By Consumer-UH12

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment less amount.
    ...               (Here prepayment amount and service charge are same and one provider coupon at checkin time)
    
    ${billable_providers}=    Billable Domain Providers    min=110   max=120
    Log   ${billable_providers}
    Set Suite Variable   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    Log  ${pro_len}
    clear_location  ${PUSERPH2}
    clear_service    ${PUSERPH2}
    clear_queue     ${PUSERPH2}
    clear_customer   ${PUSERPH2}

    ${pid}=  get_acc_id  ${PUSERPH2}
    Set Suite Variable  ${pid}

    ${resp}=  Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
   
    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=100   max=150
    # ${Tot}=   Random Int   min=100   max=150
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    # ${Tot1}=  Convert To Number  ${Tot}  1 

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${min_pre1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_time  0  15
    ${eTime}=  add_time   0  45
    ${ST_DAY}=  get_date
    ${EN_DAY}=  add_date   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${p1_sid1}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME15}
    Set Suite Variable   ${cid1}

    ${msg}=  FakerLibrary.word
    ${coupons}=  Create List  ${cupn_code}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.content}
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${balamount}=  Evaluate  ${min_pre1}-${pc_amount}
    ${balamount1}=  Convert To Number  ${balamount}  1

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
        
    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}   amountDue=0.0  


JD-TC-Payment By Consumer-13

    [Documentation]               Consumer  done payment for family member

    ${PO_Number}    Generate random string    8    123463796
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH2}${\n}
    Set Suite Variable   ${PUSERPH2}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH2}   AND  clear_service  ${PUSERPH2}  AND  clear_Item    ${PUSERPH2}  AND   clear_Coupon   ${PUSERPH2}   AND  clear_Discount  ${PUSERPH2}  AND  clear_appt_schedule   ${PUSERPH2}
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
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH2}  ${licid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH2}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.content}    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH2}  ${PASSWORD}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   ProviderLogin  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${DAY}=  get_date
    Set Suite Variable  ${DAY}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH2}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH2}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.${test_mail}  ${views}
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

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH2}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # ------------- Get general details and settings of the provider and update all needed settings
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}

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
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${p1_lid}=  Create Sample Location

    ${min_pre1}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot1}  ${bool[0]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid2}  ${resp.json()}


    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${cid}=  get_id  ${CUSERNAME5}

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}   ${p1_qid}  ${DAY}  ${p1_sid1}  ${cnote}  ${bool[0]}  ${cidfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  twodigitfloat  ${totalamt}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    ${balamount}=  twodigitfloat  ${balamount}  

    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${pid}   ${min_pre1}  ${purpose[0]}   ${wid1}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  ProviderLogin  ${PUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${wid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}   netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre1}    totalTaxAmount=${tax}
    Should Be Equal As Numbers  ${resp.json()['netRate']}   ${totalamt} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${balamount} 

    sleep   1s
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount}  ${purpose[1]}   ${wid1}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   ProviderLogin   ${PUSERPH2}  ${PASSWORD} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   01s
    ${resp}=  Get Waitlist By Id   ${wid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}    paymentStatus=${paymentStatus[2]}

***comment***

JD-TC-Payment By Consumer-UH13

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment(less amount).
   
    ${billable_providers}=    Billable   min=180   max=190
    Log   ${billable_providers}
    Set Suite Variable   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    Log  ${pro_len}
    clear_location  ${PUSERPH2}
    clear_service    ${PUSERPH2}
    clear_queue     ${PUSERPH2}
    clear_customer   ${PUSERPH2}

    ${pid}=  get_acc_id  ${PUSERPH2}
    Set Suite Variable  ${pid}

    ${resp}=  Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
   
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH2}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH2}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    # ${min_pre1}=   Random Int   min=40   max=50
    # ${Tot}=   Random Int   min=100   max=500
    # ${min_pre1}=  Convert To Number  ${min_pre1}  1
    # Set Suite Variable   ${min_pre1}
    # ${pre_float1}=  twodigitfloat  ${min_pre1}
    # Set Suite Variable   ${pre_float1}   
    # ${Tot1}=  Convert To Number  ${Tot}  1 
    # Set Suite Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  100  500  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    # ${pc_amount}=   FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_time  0  15
    ${eTime}=  add_time   0  45
    ${ST_DAY}=  get_date
    ${EN_DAY}=  add_date   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${p1_sid1}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  60  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}



     ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}
    clear_jaldeecoupon  ${jcoupon1}

    ${resp}=   Create Jaldee Coupon   ${jcoupon1}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${jcoupon1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200





    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME15}
    Set Suite Variable   ${cid1}

    ${msg}=  FakerLibrary.word
    ${coupons}=  Create List  ${cupn_code}   ${jcoupon1}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.content}
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    

    # ${msg}=  FakerLibrary.word
    # ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    
    # ${wid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${cwid}  ${wid[0]} 
    
    # ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    # ${tax}=   Evaluate  ${tax1}/100
    # ${totalamt}=  Evaluate  ${Tot1}+${tax}
    # ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    # # ${balamount1}=  Convert To Number  ${balamount}  1

    # ${min_amount}=  Evaluate  ${min_pre1} - 10
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  100  ${bool[1]}  ${cwid}  ${pid}  ${purpose[0]}  ${cid1}
    Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"     "${MINIMUM_PREPAYMENT_AMOUNT_SHOULD_BE_PROVIDED}"

    ${resp}=  Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200







*** comment ***
JD-TC-Payment By Consumer-1
    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment  first then full payment
   
    ${billable_providers}=    Billable   min=2   max=250
    Log   ${billable_providers}
    Set Suite Variable   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    Log  ${pro_len}
    clear_location  ${PUSERPH2}
    clear_service    ${PUSERPH2}
    clear_queue     ${PUSERPH2}
    clear_customer   ${PUSERPH2}

    ${pid}=  get_acc_id  ${PUSERPH2}
    Set Suite Variable  ${pid}

    ${resp}=  Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${bankid1}   ${combined_json}=  Create Sample Payment Profile
   
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Update Destination Bank  ${bankid1}  ${bool[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profiles  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bankid1}   ${pid}  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${businessFilingStatus[1]}  ${accountType[1]}  ${EMPTY}  ${EMPTY}   
    ...   razorpayMerchantId=rzp_test_tD0hiOsaNEJfpk   razorpayMerchantKey=anvXiqqxugTK3JBOlBNTONEY   razorpayWebhookMerchantKey=abcd              
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=   Get Bank Info By Id   ${bankid1}  ${pid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${p1_lid}=  Create Sample Location

    ${resp}=  Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   

    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot1}  ${bool[0]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid2}  ${resp.json()}


    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME15}
    Set Suite Variable   ${cid1}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    
    ${tax1}=  Evaluate  ${Tot1}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Tot1}+${tax}
    ${totalamt}=  twodigitfloat  ${totalamt}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    # ${balamount1}=  Convert To Number  ${balamount}  1

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
   
    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${Tot1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  
    ...   billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${min_pre1}    totalTaxAmount=${tax}
    Should Be Equal As Numbers  ${resp.json()['netRate']}   ${totalamt} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${balamount} 

    sleep   1s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount}  ${purpose[1]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   ProviderLogin   ${PUSERPH2}  ${PASSWORD} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   01s
    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}    paymentStatus=${paymentStatus[2]}


JD-TC-Payment By Consumer-2
    [Documentation]  Taking waitlist from consumer side and check prepay amount while checkin more than one person

    ${PUSERPH3}=  Evaluate  ${PUSERNAME}+100100204
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH3}${\n}
    Set Suite Variable   ${PUSERPH3}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH3}  AND  clear_service  ${PUSERPH3}  AND  clear_location  ${PUSERPH3}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=   Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    Log  ${d1}
    Log  ${sd1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH3}  ${licid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH3}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  "${resp.json()}"    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH3}  ${PASSWORD}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERPH3}  ${PASSWORD} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    ${DAY}=  get_date
    Set Suite Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${sTime}=  db.get_time
    ${eTime}=  add_time   4  15
    # ${eTime}=  add_time   0  30
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${lid}  ${resp.json()['baseLocation']['id']}
    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH3}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  pyproviderlogin  ${PUSERPH3}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200      
    # @{resp}=  uploadLogoImages
    # Should Be Equal As Strings  ${resp[1]}  200
    # ${resp}=  Get GalleryOrlogo image  logo
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['prefix']}  logo

    ${pid1}=  get_acc_id  ${PUSERPH3}
    Set Suite Variable  ${pid1}

    ${resp}=  Enable Waitlist
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${bankid2}   ${combined_json}=  Create Sample Payment Profile
   
    ${payment_profile}=  payment_profiles   ${combined_json}  ${pid1}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERPH3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Update Destination Bank  ${bankid2}  ${bool[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profiles  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Bank Info   ${bankid2}   ${pid1}  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${businessFilingStatus[1]}  ${accountType[1]}  ${EMPTY}  ${EMPTY}   
    ...   razorpayMerchantId=rzp_test_tD0hiOsaNEJfpk   razorpayMerchantKey=anvXiqqxugTK3JBOlBNTONEY   razorpayWebhookMerchantKey=abcd              
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=   Get Bank Info By Id   ${bankid2}  ${pid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERPH3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    # ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    # ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${resp}=  Enable Tax
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${ifsc_code}=   db.Generate_ifsc_code
    # ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    # ${bank_name}=  FakerLibrary.company
    # ${name}=  FakerLibrary.name
    # ${branch}=   db.get_place
    # ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH3}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
   
    # ${resp}=  payuVerify  ${pid1}
    # Log  ${resp}
    # ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH3}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  SetMerchantId  ${pid1}  ${merchantid}

    ${resp}=  Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p4_lid}  ${resp.json()[0]['id']} 

    ${prepay}=   Random Int   min=49   max=50
    ${Tot}=   Random Int   min=499   max=500
    ${prepay1}=  Convert To Number  ${prepay}  1
    Set Suite Variable   ${prepay}   ${prepay1}
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Test Variable   ${Tot}   ${Tot1}
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${prepay}  ${Tot}  ${bool[1]}  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p4_sid1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p4_lid}  ${p4_sid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p4_qid}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME4}
    Set Suite Variable   ${cid1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cid1for}   ${resp.json()}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${p4_qid}  ${DAY}  ${p4_sid1}  ${msg}  ${bool[0]}  ${cid1for}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    Set Test Variable  ${cwidfam}  ${wid[1]} 

    ${totcharge}=  Evaluate  ${Tot}*2
    ${tax1}=  Evaluate  ${totcharge}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${amount}=   Evaluate  ${prepay}*2
    ${amount}=  Convert To Number  ${amount}  1
    ${amt_float}=  twodigitfloat  ${amount}
    ${balamount}=  Evaluate  (${totcharge}+${tax})-${amount}
    # ${balamount1}=  Convert To Number  ${balamount}  1

    # ${resp}=  Make payment Consumer Mock  ${amount}  ${bool[1]}  ${cwid}  ${pid1}  ${purpose[0]}  ${cid1}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid1}  ${amount}  ${purpose[0]}  ${cwid}  ${p4_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    sleep   02s

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}

    # ${resp}=  Make payment Consumer Mock  ${balamount}  ${bool[1]}  ${cwid}  ${pid1}  ${purpose[1]}  ${cid1} 
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid1}  ${balamount}  ${purpose[1]}  ${cwid}  ${p4_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   01s
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}

    ${resp}=   ProviderLogin  ${PUSERPH3}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Waitlist By Id  ${cwid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

    ${resp}=  Get Waitlist By Id  ${cwidfam}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}