*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Coupon
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

***Keywords***

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Suite Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[1]}'
    END
    [Return]  ${subdomain}  ${resp.json()['serviceBillable']}


*** Variables ***

${SERVICE1}  Note Book101
${SERVICE2}  boots101
${SERVICE3}  pen101
${SERVICE4}  Note Book12101
${SERVICE5}  boots13101
@{Views}  self  all  customersOnly
${CUSERPH}      ${CUSERNAME}
${self}  0

*** Test Cases ***

JD-TC-WaitlistAdvancePaymentdetails-1
    [Documentation]  Get Waitlist payment details without prepayment and coupon
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+1002107
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=  Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
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
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    "${resp.json()}"    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
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
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}200.ynwtest@netvarth.com  ${views}
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
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200    
    sleep   1s
   
    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${p_id}   ${firstname}  ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ${d1} 
    Set Suite Variable   ${domains} 
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  
    Set Suite Variable   ${sub_domains}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    Set Suite Variable   ${licenses}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  add_date  10
    Set Suite Variable  ${DAY2}  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code2018}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2018}
    ${Jamount}=    Random Int   min=10  max=50
    ${Jamount}=  Convert To Number  ${Jamount}  1
    Set Suite Variable   ${Jamount}
    ${cupn_name}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    clear_jaldeecoupon  ${cupn_code2018}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  ${Jamount}  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${pid}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.word
    Set Test Variable  ${email2}  ${email}${C_Email}.ynwtest@netvarth.com
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${resp}=  Enable Waitlist
    
    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${note}=  FakerLibrary.word
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${fid}  ${resp.json()}

    ${resp}=  GetCustomer
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${businessStatus}    Random Element   ${businessStatus}  
    ${accounttype}  Random Element   ${accounttype} 
    ${fname}=   FakerLibrary.name
    ${panCardNumber}=  Generate_pan_number
    ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
    ${bankName}=  FakerLibrary.company
    ${ifsc}=  Generate_ifsc_code
    ${panname}=  FakerLibrary.name
    ${city}=   get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  payuVerify  ${pid}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}   
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
  
    ${city}=   FakerLibrary.state
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${24hours}    Random Element    ['True','False']
    ${sTime}=  add_time  5  15
    ${eTime}=  add_time   6  30
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parkingType[0]}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${loc_id1}    ${resp.json()}  
    ${description}=  FakerLibrary.sentence
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${notify}    Random Element     ['True','False'] 
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=200   max=500
    ${ser_amount}=  Convert To Number  ${ser_amount}  1
    Set Suite Variable    ${ser_amount} 
    ${min_pre}=   Random Int   min=10   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable    ${min_pre} 
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${min_pre}  ${ser_amount}  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id1}  ${resp.json()}

    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id2}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE3}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id3}  ${resp.json()}
    
    ${resp}=  Create Service  ${SERVICE5}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id5}  ${resp.json()}
    

    ${q_name}=    FakerLibrary.name
    ${strt_time}=   subtract_time  1  00
    ${end_time}=    add_time  1  00 
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=100
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}  ${s_id2}  ${s_id3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalTaxAmount}=  Evaluate  ${ser_amount} * ${gstpercentage[2]} / 100
    Set Suite Variable  ${totalTaxAmount}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid1}  ${DAY1}  ${s_id2}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     0.0
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
  
    
JD-TC-WaitlistAdvancePaymentdetails-2
    [Documentation]  Get Waitlist payment details for  prepayment service 

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid1}  ${DAY1}  ${s_id1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
  

JD-TC-WaitlistAdvancePaymentdetails-3
    [Documentation]  Get Waitlist payment details with prepayment and jaldee coupon 

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SystemNote}=  Create List  ${SystemNote[2]}  
    Set Suite Variable  ${SystemNote} 
    ${desc}=   FakerLibrary.word
    ${coupons}=  Create List   ${cupn_code2018}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid1}  ${DAY1}  ${s_id1}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        ${Jamount}
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         ${Jamount}
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    Should Be Equal As Strings  ${resp.json()['jCouponList']['${cupn_code2018}']['value']}        ${Jamount}
    Should Be Equal As Strings  ${resp.json()['jCouponList']['${cupn_code2018}']['systemNote']}   ${SystemNote}
    
JD-TC-WaitlistAdvancePaymentdetails-4
    [Documentation]    Get Waitlist advance payment details when waitlist needs Advance amount (Advance amount same as service total price).

    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200


    ${description}=  FakerLibrary.sentence
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${notify}    Random Element     ['True','False'] 
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount1}=   Random Int   min=100   max=150
    ${ser_amount1}=  Convert To Number  ${ser_amount1}  1
    Set Suite Variable    ${ser_amount1}  
    ${resp}=  Create Service  ${SERVICE4}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${ser_amount1}  ${ser_amount1}  ${bool[1]}  ${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id4}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_time  2   00
    ${eTime}=  add_time   2   15
    ${parallel}=   Random Int  min=1   max=2
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${loc_id1}  ${sid4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid2}  ${resp.json()}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    Set Suite Variable  ${pc_amount}
    ${cupn_code}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code}
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
    ${services}=   Create list   ${sid4}    ${sid1}    
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${amt}=  Evaluate   ${ser_amount1} - ${pc_amount}
    ${totalTaxAmount}=  Evaluate  ${amt} * ${gstpercentage[2]} / 100
    ${amt}=  Evaluate   ${amt} + ${totalTaxAmount}
    ${amount}=    Set Variable If  ${ser_amount1} > ${amt}   ${amt}   ${ser_amount1}


    ${desc}=   FakerLibrary.word
    ${coupons}=  Create List   ${cupn_code}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid2}  ${DAY1}  ${s_id4}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${amount}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    Should Be Equal As Strings  ${resp.json()['proCouponList']['${cupn_code}']['value']}               ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['proCouponList']['${cupn_code}']['systemNote']}          ${SystemNote}
    
  
JD-TC-WaitlistAdvancePaymentdetails-5
    [Documentation]  Get Waitlist advance payment details with prepayment and  both jaldee coupon and provider coupon 

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalTaxAmount}=  Evaluate  ${ser_amount} * ${gstpercentage[2]} / 100
    ${totalDiscount}=   Evaluate  ${pc_amount} + ${Jamount} 
    ${amt}=  Evaluate   ${min_pre} - ${totalDiscount}
    ${amt}=  Evaluate   ${amt} + ${totalTaxAmount}


    ${desc}=   FakerLibrary.word
    ${coupons}=  Create List   ${cupn_code2018}   ${cupn_code}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid1}  ${DAY1}  ${s_id1}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        ${Jamount}
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         ${totalDiscount}
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    Should Be Equal As Strings  ${resp.json()['jCouponList']['${cupn_code2018}']['value']}        ${Jamount}
    Should Be Equal As Strings  ${resp.json()['jCouponList']['${cupn_code2018}']['systemNote']}   ${SystemNote}
    Should Be Equal As Strings  ${resp.json()['proCouponList']['${cupn_code}']['value']}          ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['proCouponList']['${cupn_code}']['systemNote']}     ${SystemNote}
    
JD-TC-WaitlistAdvancePaymentdetails-6
    [Documentation]    Get Waitlist advance payment details with Enable JDN  

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${disc_max}=   Random Int   min=100   max=300
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${jdnDiscount}=  Evaluate  ${ser_amount} * ${jdn_disc_percentage[0]} / 100
    ${taxableamt}=  Evaluate  ${ser_amount} - ${jdnDiscount} 
    ${totalTaxAmount}=  Evaluate  ${taxableamt} * ${gstpercentage[2]} / 100
    ${totalTaxAmount}=  twodigitfloat  ${totalTaxAmount}
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid1}  ${DAY1}  ${s_id1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           ${jdnDiscount}
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         ${jdnDiscount}
    Should Be Equal As Numbers  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    
    
JD-TC-WaitlistAdvancePaymentdetails-7
    [Documentation]     Get Waitlist advance payment details with disabled JDN

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Disable JDN
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalTaxAmount}=  Evaluate  ${ser_amount} * ${gstpercentage[2]} / 100
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid1}  ${DAY1}  ${s_id1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    
JD-TC-WaitlistAdvancePaymentdetails-8
    [Documentation]  Get Waitlist payment details for  prepayment service (future date)

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid1}  ${DAY2}  ${s_id1}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
     
  
JD-TC-WaitlistAdvancePaymentdetails-UH1
    [Documentation]    Get Waitlist advancepayment details using Invalid account id.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist AdvancePayment Details   0  ${qid1}  ${DAY1}  ${s_id2}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    404
    Should Be Equal As Strings  "${resp.json()}"  "${ACCOUNT_NOT_EXIST}"

JD-TC-WaitlistAdvancePaymentdetails-UH2
    [Documentation]    Get Waitlist advancepayment details using service not present in any available queue.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid1}  ${DAY1}  ${s_id5}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SERVICE_NOT_EXIST}"

JD-TC-WaitlistAdvancePaymentdetails-UH3
    [Documentation]    Get Waitlist advancepayment details by using provider login.

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid1}  ${DAY1}  ${s_id2}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ACCESS_TO_URL}"

JD-TC-WaitlistAdvancePaymentdetails-UH4
    [Documentation]    Get Waitlist advancepayment details without login.

    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid1}  ${DAY1}  ${s_id2}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-WaitlistAdvancePaymentdetails-UH5
    [Documentation]    Get Waitlist advancepayment details using Invalid coupon code.

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${INVALID_Coupon}=  Create List   0
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid1}  ${DAY1}  ${s_id2}  ${desc}  ${bool[0]}  ${INVALID_Coupon}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${COUPON_INVALID}"


JD-TC-WaitlistAdvancePaymentdetails-UH6
    [Documentation]    Get Waitlist advancepayment details by applying a coupon.(If Coupon start date is a future date)
    
    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${cupn_code1}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code1}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_time  0  15
    ${eTime}=  add_time   0  45
    ${ST_DAY}=  add_date   1
    ${EN_DAY}=  add_date   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid4}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code1}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId1}  ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalTaxAmount}=  Evaluate  ${ser_amount1} * ${gstpercentage[2]} / 100
    ${SystemNote1}=  Create List   PROVIDER_COUPON_NOT_APPLICABLE

    ${desc}=   FakerLibrary.word
    ${coupons}=  Create List   ${cupn_code1}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid2}  ${DAY1}  ${s_id4}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    Should Be Equal As Strings  ${resp.json()['proCouponList']['${cupn_code1}']['value']}               0.0
    Should Be Equal As Strings  ${resp.json()['proCouponList']['${cupn_code1}']['systemNote']}          ${SystemNote1}
    
   

JD-TC-WaitlistAdvancePaymentdetails-UH7
    [Documentation]  Consumer apply a coupon at Checkin time.but coupon rule contain  maxConsumerUseLimitPerProvider is one

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code2021}=    FakerLibrary.word
    ${Jamount1}=    Random Int   min=10  max=50
    ${Jamount1}=  Convert To Number  ${Jamount1}  1
    ${cupn_name}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    clear_jaldeecoupon  ${cupn_code2021}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2021}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  ${Jamount1}  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2021}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2021}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2021}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2021}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    ${coupons}=  Create List   ${cupn_code2021}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid2}  ${DAY1}  ${s_id4}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid2}  ${DAY1}  ${s_id4}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]}  
    
    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${desc}=   FakerLibrary.word
    ${coupons}=  Create List   ${cupn_code2021}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${qid1}  ${DAY1}  ${s_id1}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY3}=  add_date  1
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid2}  ${DAY1}  ${s_id4}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid1}  ${wid[0]} 

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${cwid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
