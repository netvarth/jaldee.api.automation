*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Payment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


***Variables***
${invoice_purpose}  subscriptionLicenseInvoicePayment
${digits}       0123456789
${self}         0
@{service_duration}   5   20

***Keywords***

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == 'True'
    END
    [Return]  ${subdomain}  ${resp.json()['serviceBillable']}


*** Test Cases ***

JD-TC-Create Payment-1
    [Documentation]   Add to waitlist 3 consumers when queue capaciy is 3 and make prepayment

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+100100748
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_location  ${PUSERPH0}   AND   clear_service   ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=   Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END

    ${pkg_id}=   get_highest_license_pkg
    Set Suite Variable  ${lic1}   ${pkg_id[0]}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}    ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+100100302
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH1}${\n}
    
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+100100303
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH2}${\n}
    
    ${PUSERMAIL0}=   Set Variable  ${P_Email}ph301.ynwtest@netvarth.com
    ${views}=  Evaluate  random.choice($Views)  random
    Log   ${views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   FakerLibrary.state
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${sTime}=  add_time  0  15
    ${eTime}=  add_time   0  30 
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep   01s

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   


    ${pid0}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${pid0}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  get_date
    Set Suite Variable  ${DAY} 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.get_time
    ${eTime}=  add_time   0  15
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()}
    
    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    Set Suite Variable   ${min_pre}
    ${servicecharge}=   Random Int  min=100  max=500
    Set Suite Variable   ${servicecharge}
    ${Total1}=  Convert To Number  ${servicecharge}  1 
    Set Suite Variable   ${Total}   ${Total1}
    ${amt_float}=  twodigitfloat  ${Total}
    Set Suite Variable  ${amt_float}  ${amt_float}  

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration[1]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2}

    ${servicecharge2}=   Random Int  min=100  max=500
    Set Suite Variable   ${servicecharge2}
    Set Suite Variable   ${min_pre2}   ${servicecharge2}
    ${Total2}=  Convert To Number  ${servicecharge2}  1 
    Set Suite Variable   ${Total2}
    ${amt_float2}=  twodigitfloat  ${Total2}
    Set Suite Variable  ${amt_float2} 

    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration[1]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre2}  ${Total2}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${sTime1}=  add_time  0  00
    ${eTime1}=  add_time   1  30
    ${p1queue1}=    FakerLibrary.word
    
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1   5   ${p1_l1}  ${p1_s1}  ${p1_s2}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id}  ${resp.json()[0]['jaldeeConsumer']}

    # ${cons_id}=  get_id  ${CUSERNAME8}     
    # Set Suite Variable  ${cons_id} 

    # ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    # ${ifsc_code}=   db.Generate_ifsc_code
    # ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    # ${bank_name}=  FakerLibrary.company
    # ${name}=  FakerLibrary.name
    # ${branch}=   db.get_place
    # ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  payuVerify  ${pid0}
    # Log  ${resp}

    # ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=   Get Account Payment Settings 
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  SetMerchantId  ${pid0}  ${merchantid}
    
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[0]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[1]}

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${consumer_id}  ${resp.json()['id']}
    
    ${resp}=  Make payment Consumer Mock  ${pid0}  ${min_pre}  ${purpose[0]}  ${wid}  ${p1_s1}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${min_pre}  ${bool[1]}  ${wid}  ${pid0}  ${purpose[0]}   ${cid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}
    Verify Response  ${resp}   paymentStatus=${paymentStatus[1]}

    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[1]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}

    ${resp}=  AddCustomer  ${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id1}  ${resp.json()[0]['jaldeeConsumer']}

    # ${cons_id1}=  get_id  ${CUSERNAME9}     
    # Set Suite Variable  ${cons_id1}

    ${resp}=  Add To Waitlist  ${cid1}  ${p1_s1}  ${p1_q1}  ${DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[0]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[1]}

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${consumer_id1}  ${resp.json()['id']}
    
    ${resp}=  Make payment Consumer Mock  ${pid0}  ${min_pre}  ${purpose[0]}  ${wid1}  ${p1_s1}  ${bool[0]}   ${bool[1]}  ${consumer_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${min_pre}  ${bool[1]}  ${wid1}  ${pid0}  ${purpose[0]}   ${cid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[1]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}

    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[1]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}

    ${resp}=  AddCustomer  ${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id2}  ${resp.json()[0]['jaldeeConsumer']}

    # ${cons_id2}=  get_id  ${CUSERNAME10}     
    # Set Suite Variable  ${cons_id2}

    ${resp}=  Add To Waitlist  ${cid2}  ${p1_s1}  ${p1_q1}  ${DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[0]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[1]}

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${consumer_id2}  ${resp.json()['id']} 

    ${resp}=  Make payment Consumer Mock  ${pid0}  ${min_pre}  ${purpose[0]}  ${wid2}  ${p1_s1}  ${bool[0]}   ${bool[1]}  ${consumer_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${min_pre}  ${bool[1]}  ${wid2}  ${pid0}  ${purpose[0]}   ${cid2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get consumer Waitlist By Id  ${wid2}  ${pid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[1]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}

    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[1]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}



JD-TC-Create Payment-2
    [Documentation]   Add To Waitlist Consumers with Coupon, after that Consumer completes prepayment of that service where Prepayment_amount same as service_amount
    ${domains}=  Jaldee Coupon Target Domains  ${d1} 
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1} 
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200       
    ${cup_code}=   FakerLibrary.word
    Set Suite Variable   ${cup_code}
    ${cup_name}=    FakerLibrary.name
    Set Suite Variable   ${cup_name}
    ${cup_des}=    FakerLibrary.sentence
    Set Suite Variable   ${cup_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}  
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon     ${cup_code}

    ${resp}=  Create Jaldee Coupon  ${cup_code}  ${cup_name}  ${cup_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  99  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cup_code}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Push Jaldee Coupon  ${cup_code}  ${cup_des}
    Should Be Equal As Strings  ${resp.status_code}  200 
    comment  1
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code   ${cup_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}

    ${resp}=  Enable Jaldee Coupon By Provider  ${cup_code}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cup_code}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  06s
    
    ${resp}=  AddCustomer  ${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid18}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id18}  ${resp.json()[0]['jaldeeConsumer']}

    # ${cons_id18}=  get_id  ${CUSERNAME18}     
    # Set Suite Variable  ${cons_id18} 

    ${DAY}=  get_date
    ${desc}=   FakerLibrary.sentence  

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${consumer_id3}  ${resp.json()['id']} 

    ${msg}=  FakerLibrary.word
    ${coupons}=  Create List  ${cup_code}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid0}  ${p1_q1}  ${DAY}  ${p1_s2}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid18}  ${wid[0]} 
    ${resp}=  Get consumer Waitlist By Id  ${wid18}  ${pid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${min_pre2}   ${resp.json()['amountDue']} 
    Verify Response  ${resp}   waitlistStatus=${wl_status[3]}
    Verify Response  ${resp}   paymentStatus=${paymentStatus[0]}
    
    ${resp}=  Make payment Consumer Mock  ${pid0}  ${min_pre2}  ${purpose[0]}  ${wid18}  ${p1_s2}  ${bool[0]}   ${bool[1]}  ${consumer_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${PAYMENT_AMOUNT_IS_NOT_MATCHED}
    # ${resp}=  Make payment Consumer Mock  ${min_pre2}  ${bool[1]}  ${wid18}  ${pid0}  ${purpose[0]}   ${cid18}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # sleep   02s

    # ${resp}=  Get consumer Waitlist By Id  ${wid18}  ${pid0}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}   waitlistStatus=${wl_status[0]}  
       

    # ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Waitlist By Id  ${wid18} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}   waitlistStatus=${wl_status[0]}
       

    # ${resp}=  Get Bill By UUId  ${wid18}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['uuid']}   ${wid18}
    # Verify Response  ${resp}  billPaymentStatus=${paymentStatus[2]}   totalAmountPaid=${Total2}  amountDue=-50.0


JD-TC-Create Payment-3
    [Documentation]   Add to waitlist 3 consumers when queue capaciy is 3 and make prepayment(online checkin)
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${consumer_id4}  ${resp.json()['id']} 
    
    ${DAY1}=  add_date   4
    ${cid}=  get_id  ${CUSERNAME5} 
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY1}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[0]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[3]}
    
    ${resp}=  Make payment Consumer Mock  ${pid0}  ${min_pre}  ${purpose[0]}  ${wid1}  ${p1_s1}  ${bool[0]}   ${bool[1]}  ${consumer_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${min_pre}  ${bool[1]}  ${wid1}  ${pid0}  ${purpose[0]}   ${cid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${pid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[1]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}

    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[1]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${consumer_id5}  ${resp.json()['id']} 
    
    ${cid1}=  get_id  ${CUSERNAME6} 
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY1}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${wid2}  ${pid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[0]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[3]}
    
    ${resp}=  Make payment Consumer Mock  ${pid0}  ${min_pre}  ${purpose[0]}  ${wid2}  ${p1_s1}  ${bool[0]}   ${bool[1]}  ${consumer_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${min_pre}  ${bool[1]}  ${wid2}  ${pid0}  ${purpose[0]}   ${cid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get consumer Waitlist By Id  ${wid2}  ${pid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[1]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}

    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[1]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Set Suite Variable  ${consumer_id7}  ${resp.json()['id']}   

    ${cid2}=  get_id  ${CUSERNAME7} 
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p1_q1}  ${DAY1}  ${p1_s1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${wid3}  ${pid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[0]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${pid0}  ${min_pre}  ${purpose[0]}  ${wid3}  ${p1_s1}  ${bool[0]}   ${bool[1]}  ${consumer_id7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get consumer Waitlist By Id  ${wid3}  ${pid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[1]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}

    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[1]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}


JD-TC-Create Payment-4
    [Documentation]   Create a Payment for a invoice (Here bussiness profile is inactive and try to get invoice)
    
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name   
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+5101138
    ${PUSEREMAIL}=  Set Variable  ${P_Email}${PUSERNAME_B}.ynwtest@netvarth.com
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${PUSEREMAIL}  ${d1}  ${sd}  ${PUSERNAME_B}    4
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSEREMAIL}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSEREMAIL}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_B}${\n}
    Set Suite Variable  ${PUSERNAME_B}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${resp}=  Create Business Profile without details  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Addons Metadata
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${aId}  ${resp.json()[0]['addons'][0]['addonId']}
    ${resp}=  Add addon  ${aId}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Invoices  NotPaid
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}  []

    # Set Suite Variable  ${uid}  ${resp.json()[0]['ynwUuid']}
    # Set Test Variable  ${amount}  ${resp.json()[0]['amount']}
    # ${amount}=  Convert To Number  ${amount}  2
    # ${amt}=  Evaluate  "%.2f" % ${amount}
    # ${resp}=  Make Payment  ${amount}  ${payment_modes[1]}  ${uid}  ${invoice_purpose}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=${amt} /></td>
    # Should Contain  ${resp.json()['response']}  \"merchantId\":\"6774522\"
    # Should Contain  ${resp.json()['response']}  <td><input name=\"firstname\" id=\"firstname\" value=${firstname} /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${PUSEREMAIL} /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"phone\" value=${PUSERNAME_B} ></td>\n
    # Should Contain  ${resp.json()['response']}  <td>Success URI: </td>\n          <td colspan=\"3\"><input name=\"surl\"  size=\"64\" value=${BASE_URL}/provider/payment/success></td>
    # Should Contain  ${resp.json()['response']}  <td>Failure URI: </td>\n          <td colspan=\"3\"><input name=\"furl\" value=${BASE_URL}/provider/payment/failure size=\"64\" ></td> 
    # ${resp}=  Make Payment Mock  ${amount}  ${bool[1]}  ${uid}  ${invoice_purpose}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Get Invoices  Paid
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${count}=  Get Length  ${resp.json()} 
    # Should Be Equal As Integers  ${count}  1
    # Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uid}

JD-TC-Create Payment-5
    [Documentation]   Create a  failed payment

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name   
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+5101134
    ${PUSEREMAIL}=  Set Variable  ${P_Email}${PUSERNAME_B}.ynwtest@netvarth.com
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${PUSEREMAIL}  ${d1}  ${sd}  ${PUSERNAME_B}    4
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSEREMAIL}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSEREMAIL}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_B}${\n}
    Set Suite Variable  ${PUSERNAME_B}

    ${DAY}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+100100302
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH1}${\n}
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+100100303
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH2}${\n}
    ${PUSERMAIL0}=   Set Variable  ${P_Email}ph301.ynwtest@netvarth.com
    ${views}=  Evaluate  random.choice($Views)  random
    Log   ${views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   FakerLibrary.state
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${sTime}=  add_time  0  15
    ${eTime}=  add_time   0  30 
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep   01s

    ${pid1}=  get_acc_id  ${PUSERNAME_B}
    Set Suite Variable  ${pid1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Invoice Generartion   ${pid1}    ${bool[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200

    # ${DAY1}=  get_date
    # Set Suite Variable  ${DAY1}  ${DAY1}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # Set Suite Variable  ${list}  ${list}
    # ${resp}=  Create Business Profile without details  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Addons Metadata
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${aId}  ${resp.json()[0]['addons'][0]['addonId']}

    ${resp}=  Add addon  ${aId}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Invoices  ${paymentStatus[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${uid1}  ${resp.json()[0]['ynwUuid']}
    Set Test Variable  ${amount}  ${resp.json()[0]['amountToPay']}
   
    ${resp}=  Make Payment Mock  ${amount}  ${bool[0]}  ${uid1}  ${invoice_purpose}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoices  ${paymentStatus[5]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  0

    ${resp}=  Get Invoices  ${paymentStatus[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uid1}

JD-TC-Create Payment-UH1

    [Documentation]   pay partial amount

    ${resp}=  ProviderLogin  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoices  ${paymentStatus[0]}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${uid1}  ${resp.json()[0]['ynwUuid']}
    Set Test Variable  ${amount}  ${resp.json()[0]['amount']}
    ${amount}=  Evaluate  ${amount}-1

    ${resp}=  Make Payment Mock  ${amount}  ${bool[1]}  ${uid1}  ${invoice_purpose}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${INVOICE_AMOUNT_MISMATCH}"

JD-TC-Create Payment-UH2

    [Documentation]   pay more amount

    ${resp}=  ProviderLogin  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoices  ${paymentStatus[0]}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${uid1}  ${resp.json()[0]['ynwUuid']}
    Set Test Variable  ${amount}  ${resp.json()[0]['amount']}
    ${amount}=  Evaluate  ${amount}+1

    ${resp}=  Make Payment Mock  ${amount}  ${bool[1]}  ${uid1}  ${invoice_purpose}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${INVOICE_AMOUNT_MISMATCH}"

JD-TC-Create Payment-6

    [Documentation]   Create a Payment for a invoice
    
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name   
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+5101139
    ${PUSEREMAIL}=  Set Variable  ${P_Email}${PUSERNAME_C}.ynwtest@netvarth.com
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${PUSEREMAIL}  ${d1}  ${sd}  ${PUSERNAME_C}    9
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSEREMAIL}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSEREMAIL}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}

    ${pid2}=  get_acc_id  ${PUSERNAME_C}
    Set Suite Variable  ${pid2}
   
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Invoice Generartion   ${pid2}    ${bool[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    ${resp}=  Create Business Profile without details  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Addons Metadata
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${aId}  ${resp.json()[0]['addons'][0]['addonId']}

    ${resp}=  Add addon  ${aId}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Invoices   ${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}  []

    ${DAY}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+100100302
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH1}${\n}
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+100100303
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH2}${\n}
    ${PUSERMAIL0}=   Set Variable  ${P_Email}ph301.ynwtest@netvarth.com
    ${views}=  Evaluate  random.choice($Views)  random
    Log   ${views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   FakerLibrary.state
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${sTime}=  add_time  0  15
    ${eTime}=  add_time   0  30 
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   01s

    ${resp}=   Get Addons Metadata
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${aId}  ${resp.json()[0]['addons'][0]['addonId']}
   
    ${licresp}=   Get upgradable license
    Should Be Equal As Strings    ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    ${index_list}=  Create List   0  1  2  3  4  
    ${index}=  Random Element    ${index_list}
    # ${index}=  Evaluate  ${liclen}/2
    Set Suite Variable  ${pkgId}  ${licresp.json()[${index}]['pkgId']}
    Set Suite Variable  ${lprice1}  ${licresp.json()[${index}]['price']}

    ${resp}=  Change License Package  ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Invoices  ${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${uid}  ${resp.json()[0]['ynwUuid']}
    Set Test Variable  ${amount}  ${resp.json()[0]['amountToPay']}
    ${amount}=  Convert To Number  ${amount}  2
    
    # ${resp}=  Make Payment Mock  ${amount}  ${bool[1]}  ${uid}  ${invoice_purpose}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Accept Payment  ${uid}  ${payment_modes[0]}  ${amount}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoices  ${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  2s
    ${resp}=  Get Invoices  ${paymentStatus[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uid}

JD-TC-Create Payment-7
    [Documentation]   Add a new customer and take waitlist from provider side and accept payment
    
    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phone}=  Evaluate  ${PUSERPH0}+72004
    Set Suite Variable    ${phone}   
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${phone}   firstName=${firstname}   lastName=${lastname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${N_cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${phone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${jaldeeid}    ${resp.json()[0]['jaldeeId']}
    
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Add To Waitlist  ${N_cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${desc}  ${bool[0]}  ${N_cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[0]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[1]}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=${Total}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${Total}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${Total}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${P1SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${Total}

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  ${Total}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${Total}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY}
    
JD-TC-Create Payment-8
    [Documentation]   Take wailist for a new added customer and after consumer signup consumer doing mock payment

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+73007
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${phone}    ${alternativeNo}  ${dob}  ${gender}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${phone}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${phone}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login   ${phone}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${email}  ${firstname}${phone}${C_Email}.ynwtest@netvarth.com
    ${resp}=  Update Consumer Profile With Emailid    ${firstname}  ${lastname}  ${address}   ${dob}  ${gender}  ${email}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=   FakerLibrary.sentence
    ${DAY}=   add_date   2
    ${resp}=  Add To Waitlist  ${N_cid}  ${p1_s2}  ${p1_q1}  ${DAY}  ${desc}  ${bool[0]}  ${N_cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[0]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[0]}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login   ${phone}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consumer_id8}  ${resp.json()['id']} 

    ${resp}=  Make payment Consumer Mock  ${pid0}  ${Total2}  ${purpose[1]}  ${wid}  ${p1_s2}  ${bool[0]}   ${bool[1]}  ${consumer_id8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
    sleep   02s
    ${resp}=  Get Payment Details  account-eq=${pid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${Total2} 
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid0}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[1]}

    ${resp}=  Get Bill By consumer  ${wid}  ${pid0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=${Total2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=${Total2}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${Total2}  amountDue=0.0   


JD-TC-Create Payment-9
    [Documentation]   Create a Payment for a invoice after a failed attempt.
    
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name   
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+5101475
    ${PUSEREMAIL}=  Set Variable  ${P_Email}${PUSERNAME_C}.ynwtest@netvarth.com
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${PUSEREMAIL}  ${d1}  ${sd}  ${PUSERNAME_C}    9
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSEREMAIL}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSEREMAIL}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}
    
    ${pid2}=  get_acc_id  ${PUSERNAME_C}
    Set Suite Variable  ${pid2}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Invoice Generartion   ${pid2}    ${bool[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    ${resp}=  Create Business Profile without details  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Addons Metadata
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${aId}  ${resp.json()[0]['addons'][0]['addonId']}

    ${resp}=  Add addon  ${aId}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Invoices  ${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}  []

    ${DAY}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+100100302
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH1}${\n}
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+100100303
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH2}${\n}
    ${PUSERMAIL0}=   Set Variable  ${P_Email}ph301.ynwtest@netvarth.com
    ${views}=  Evaluate  random.choice($Views)  random
    Log   ${views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   FakerLibrary.state
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${sTime}=  add_time  0  15
    ${eTime}=  add_time   0  30 
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   01s

    ${resp}=   Get Addons Metadata
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${aId}  ${resp.json()[0]['addons'][0]['addonId']}
   
    ${licresp}=   Get upgradable license
    Should Be Equal As Strings    ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    ${index_list}=  Create List   0  1  2  3  4  
    ${index}=  Random Element    ${index_list}
    # ${index}=  Evaluate  ${liclen}/2
    Set Suite Variable  ${pkgId}  ${licresp.json()[${index}]['pkgId']}
    Set Suite Variable  ${lprice1}  ${licresp.json()[${index}]['price']}

    ${resp}=  Change License Package  ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Invoices  ${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Suite Variable  ${uid}  ${resp.json()[0]['ynwUuid']}
    Set Test Variable  ${amount}  ${resp.json()[0]['amountToPay']}
    ${amount}=  Convert To Number  ${amount}  2
    
    ${resp}=  Make Payment Mock  ${amount}  ${bool[0]}  ${uid}  ${invoice_purpose}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoices  ${paymentStatus[5]}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  0
 
    ${resp}=  Make Payment Mock  ${amount}  ${bool[1]}  ${uid}  ${invoice_purpose}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoices  ${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s
    ${resp}=  Get Invoices  ${paymentStatus[5]}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${uid}

JD-TC-Create Payment-10
    [Documentation]   Create a service with same service amount and prepayment amount then do the prepayment(wailist).

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name   
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+5101775
    Set Suite Variable  ${PUSERNAME_C}
    ${PUSEREMAIL}=  Set Variable  ${P_Email}${PUSERNAME_C}.ynwtest@netvarth.com
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${PUSEREMAIL}  ${d1}  ${sd}  ${PUSERNAME_C}    9
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSEREMAIL}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSEREMAIL}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${resp}=  Create Business Profile without details  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${DAY}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+100100302
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH1}${\n}
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+100100303
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH2}${\n}
    ${PUSERMAIL0}=   Set Variable  ${P_Email}ph301.ynwtest@netvarth.com
    ${views}=  Evaluate  random.choice($Views)  random
    Log   ${views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   FakerLibrary.state
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${sTime}=  add_time  0  15
    ${eTime}=  add_time   0  30 
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   01s

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${pid0}=  get_acc_id  ${PUSERNAME_C}
    Set Suite Variable  ${pid0}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  get_date
    Set Suite Variable  ${DAY} 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.get_time
    ${eTime}=  add_time   0  15
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()}
    
    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    Set Suite Variable   ${min_pre}
    # ${servicecharge}=   Random Int  min=100  max=500
    # Set Suite Variable   ${servicecharge}
    ${Total1}=  Convert To Number  ${min_pre}  1 
    Set Suite Variable   ${Total}   ${Total1}
    ${amt_float}=  twodigitfloat  ${Total}
    Set Suite Variable  ${amt_float}  ${amt_float}  

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration[1]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${sTime1}=  add_time  0  00
    ${eTime1}=  add_time   1  30
    ${p1queue1}=    FakerLibrary.word
    
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1   5   ${p1_l1}  ${p1_s1}  
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_q1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id}  ${resp.json()[0]['jaldeeConsumer']}
    
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[0]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[1]}

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${Total}

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${consumer_id}  ${resp.json()['id']}
    
    ${resp}=  Make payment Consumer Mock  ${pid0}  ${min_pre}  ${purpose[0]}  ${wid}  ${p1_s1}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By UUId  ${wid}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${Total}
    # Should Be Equal As Strings  ${resp.json()['netTotal']}  ${Total}

JD-TC-Create Payment-11
    [Documentation]   Create a service with same service amount and prepayment amount then do the prepayment(appointment).

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${p1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${p1_s1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[1]}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${Total}

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${consumer_id}  ${resp.json()['id']}
    
    ${resp}=  Make payment Consumer Mock  ${pid0}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${p1_s1}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By UUId  ${apptid1}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${Total}
    # Should Be Equal As Strings  ${resp.json()['netTotal']}  ${Total}

JD-TC-Create Payment-12
    [Documentation]   Create a service with same service amount and prepayment amount then do the prepayment(wailist)Tax enabled.

    clear_service    ${PUSERNAME_C}
    clear_queue     ${PUSERNAME_C}
    clear_customer   ${PUSERNAME_C}

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${DAY}=  get_date
    Set Test Variable  ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7

    # ${p1_l1}=  Create Sample Location

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    Set Suite Variable   ${min_pre}
    # ${servicecharge}=   Random Int  min=100  max=500
    # Set Suite Variable   ${servicecharge}
    ${Total1}=  Convert To Number  ${min_pre}  1 
    Set Suite Variable   ${Total}   ${Total1}
    ${amt_float}=  twodigitfloat  ${Total}
    Set Suite Variable  ${amt_float}  ${amt_float}  

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration[1]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${p1_s1}  ${resp.json()}
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   30
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_sid1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_qid}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id}  ${resp.json()[0]['jaldeeConsumer']}
    
    ${resp}=  Add To Waitlist  ${cid}  ${p1_sid1}  ${p1_qid}  ${DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   paymentStatus=${paymentStatus[0]}
    Verify Response  ${resp}   waitlistStatus=${wl_status[1]}

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${Total}

    ${tax1}=  Evaluate  ${Total}*${gstpercentage[3]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${Total}+${tax}
    ${totalamt}=  twodigitfloat  ${totalamt}
    # ${totalamt}=  Evaluate  round(${totalamt}) 
    Set Suite Variable   ${totalamt}
    ${balamount}=  Evaluate  ${totalamt}-${min_pre}
    ${balamount}=  Round Val  ${balamount}  2
    ${balamount}=  twodigitfloat  ${balamount}

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${consumer_id}  ${resp.json()['id']}
    
    ${resp}=  Make payment Consumer Mock  ${pid0}  ${totalamt}  ${purpose[0]}  ${wid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create Payment-13

    [Documentation]   Create a service with same service amount and prepayment amount then do the prepayment(Appointment)Tax enabled.

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${p1_sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${p1_sid1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[1]}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${Total}
    Should Be Equal As Strings  ${resp.json()['netTotal']}  ${Total}

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${consumer_id}  ${resp.json()['id']}
    
    ${resp}=  Make payment Consumer Mock  ${pid0}  ${totalamt}  ${purpose[0]}  ${apptid1}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200