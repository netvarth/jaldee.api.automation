*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        JDN
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

*** Variables ***
${item1}           ITEM1
${itemCode1}       itemCode1
${DisplayName1}   item1_DisplayName
${discount}        Disc11
${coupon}          wheat
${SERVICE1}        SERVICE1
${SERVICE2}        SERVICE2
${SERVICE3}        SERVICE3
${self}             0

*** Test Cases ***

JD-TC-JDN Highlevel-1
	[Documentation]  Enable JDN and check bill after applying provider discount, provider coupon, Jaldee Coupon and item to non taxable services.

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

        ${subdomain}=  Get Billable Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Test Variable   ${subdomain}
        Exit For Loop IF    '${subdomain}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+9578      
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_Z}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Z}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Z}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_Z}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${p_id}  ${resp.json()['id']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.ynwtest@netvarth.com
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
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
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${disc_max}=   FakerLibrary.Pyfloat  positive=True  left_digits=4  right_digits=1
    Set Suite Variable   ${disc_max}
    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_Z}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${p_id}   ${firstname}  ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   01s
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[0]}
    Should Be Equal As Strings   ${resp.json()['discMax']}          ${disc_max}
    Should Be Equal As Strings   ${resp.json()['status']}           ${Qstate[0]}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${alldomains}=  Jaldee Coupon Target Domains  ALL
    ${allsub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${licenses}=  Jaldee Coupon Target License  ${pkg_id[0]}

    ${cupn_code}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon  ${cupn_code}

    ${resp}=  Create Jaldee Coupon  ${cupn_code}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${alldomains}  ${allsub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Create Sample Jaldee Coupon
    # Log  ${resp.json()}
    # Set Suite Variable   ${cupn_code}     ${resp.json()['jaldeeCouponCode']}
    # Set Suite Variable   ${cupn_name}     ${resp.json()['couponName']}
    # Set Suite Variable   ${cupn_des}      ${resp.json()['couponDescription']}
    ${resp}=  Push Jaldee Coupon  ${cupn_code}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode   ${cupn_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${jaldee_amt}    ${resp.json()['discountValue']}  

    ${resp}=  SuperAdmin Logout 
    Log    ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code    ${cupn_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
     
    ${desc}=  FakerLibrary.sentence
    Set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    Set Suite Variable   ${ser_durtn}
    ${ser_amount}=   Random Int   min=1000   max=1000
    ${ser_amount}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}
    ${ser_amount1}=   Random Int   min=2000   max=2000
    ${ser_amount1}=   Convert To Number   ${ser_amount1}
    Set Suite Variable   ${ser_amount1}
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}
    ${ser_amount2}=   Random Int   min=2000   max=2000
    ${ser_amount2}=   Convert To Number   ${ser_amount2}
    Set Suite Variable   ${ser_amount2}
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount2}  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()}

    ${desc}=  FakerLibrary.Sentence   nb_words=2
    Set Suite Variable    ${desc}
    # ${disc_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    ${disc_amount}=  Set Variable    10.0
    Set Suite Variable    ${disc_amount}
    ${resp}=   Create Discount  ${discount}   ${desc}    ${disc_amount}   ${calctype[1]}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${disc_id}   ${resp.json()}
    ${resp}=   Get Discount By Id  ${disc_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}   id=${disc_id}   name=${discount}   description=${desc}    discValue=${disc_amount}   calculationType=${calctype[1]}  status=${status[0]}
    
    ${des}=  FakerLibrary.Word
    ${description}=  FakerLibrary.sentence
    # ${item_amount}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
    ${item_amount}=  Set Variable    50.0
    Set Suite Variable    ${item_amount}
    # ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${item_amount}    ${bool[0]}
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${item_amount}  ${bool[0]}    
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id}  ${resp.json()}

    # ${coupon_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1

    # ${coupon_amount}=  Set Variable    10.0
    # Set Suite Variable    ${coupon_amount}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${coupon_amount}=  Set Variable    10.0
    Set Suite Variable    ${coupon_amount}
    ${cupn_code1}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code1}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=150
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid1}   ${sid2}  ${sid3}
    ${items}=  Create List   ${item_id}
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${coupon_amount}  ${calctype[1]}  ${cupn_code1}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  items=${items}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${coupon_id}  ${resp.json()}
    
    # ${resp}=  Create Coupon  ${coupon}  ${desc}  ${coupon_amount}  ${calctype[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${coupon_id}  ${resp.json()}
    ${resp}=  Get Coupon By Id  ${coupon_id} 
    Verify Response  ${resp}  name=${coupon}  description=${desc}  amount=${coupon_amount}  calculationType=${calctype[1]}  status=${status[0]}
    
    # ${des}=  FakerLibrary.Word
    # ${description}=  FakerLibrary.sentence
    # # ${item_amount}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
    # ${item_amount}=  Set Variable    50.0
    # Set Suite Variable    ${item_amount}
    # # ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${item_amount}    ${bool[0]}
    # ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${item_amount}  ${bool[0]}    
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${item_id}  ${resp.json()}

    # ${cid}=  get_id  ${CUSERNAME3}
    # Set Suite Variable  ${cid}
    
    # ${desc}=  FakerLibrary.sentence
    # Set Suite Variable   ${desc}
    # ${ser_durtn}=   Random Int   min=2   max=10
    # Set Suite Variable   ${ser_durtn}
    # ${ser_amount}=   Random Int   min=1000   max=1000
    # ${ser_amount}=   Convert To Number   ${ser_amount}
    # Set Suite Variable   ${ser_amount}
    # ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sid1}  ${resp.json()}
    # ${ser_amount1}=   Random Int   min=2000   max=2000
    # ${ser_amount1}=   Convert To Number   ${ser_amount1}
    # Set Suite Variable   ${ser_amount1}
    # ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}  ${bool[0]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sid2}  ${resp.json()}
    # ${ser_amount2}=   Random Int   min=2000   max=2000
    # ${ser_amount2}=   Convert To Number   ${ser_amount2}
    # Set Suite Variable   ${ser_amount2}
    # ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount2}  ${bool[0]}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sid3}  ${resp.json()}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${capacity}=   Random Int   min=20   max=100
    ${parallel}=   Random Int   min=1   max=2
    ${sTime}=  add_timezone_time  ${tz}  0  30  
    ${eTime}=  add_timezone_time  ${tz}  4  00  
    ${queue1}=   FakerLibrary.word
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${sid1}  ${sid2}   ${sid3}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    ${c_note}=   FakerLibrary.word
    Set Suite Variable   ${c_note}
    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${total}=         Evaluate   ${ser_amount} * ${jdn_disc_percentage[0]}
    ${total}=         Convert To Number   ${total}   2
    ${net_rate}=      Evaluate    ${total} / 100  
    ${net_rate}=      Convert To Number   ${net_rate}   2
    ${amount}=        Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=     Evaluate   ${ser_amount} - ${amount}
    ${net_rate1}=     Convert To Number   ${net_rate1}     2

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid1}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid}  ${action[12]}  ${cupn_code1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${net_total}=           Evaluate   ${ser_amount} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amt1} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${net_rate1}=           Evaluate   ${net_rate1} - ${jaldee_amt}

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}     
 
JD-TC-JDN Highlevel-2
	[Documentation]  Enable JDN and check bill after applying provider discount, provider coupon, Jaldee Coupon and item to taxable services.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${GST_num}   ${PAN_num}=  Generate_gst_number  ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[1]}   ${GST_num} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
    # ${cid1}=  get_id  ${CUSERNAME4}
    # Set Suite Variable  ${cid1}
    ${resp}=  Add To Waitlist  ${cid1}  ${sid3}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid1[0]}

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid1}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid1}  ${action[12]}  ${cupn_code1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid1}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${net_total}=           Evaluate   ${ser_amount2} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount2} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amt1} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${final_amount}=        Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount1}=        Convert To Number   ${final_amount}   2
    ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}      
   
JD-TC-JDN Highlevel-3
	[Documentation]  Enable JDN and check bill after adding taxable service, provider discount, provider coupon, Jaldee Coupon and item to non taxable service bill.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    # ${cid2}=  get_id  ${CUSERNAME4}
    # Set Suite Variable  ${cid2}
    ${resp}=  Add To Waitlist  ${cid1}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${total}=         Evaluate   ${ser_amount} * ${jdn_disc_percentage[0]}
    ${total}=         Convert To Number   ${total}   2
    ${net_rate}=      Evaluate    ${total} / 100  
    ${net_rate}=      Convert To Number   ${net_rate}   2
    ${amount}=        Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=     Evaluate   ${ser_amount} - ${amount}
    ${net_rate1}=     Convert To Number   ${net_rate1}     2

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1   
    ${resp}=  Update Bill  ${wid}  ${action[0]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=   FakerLibrary.word
    ${disc1}=  Bill Discount Input  ${disc_id}  ${reason}   ${reason}
    ${bdisc}=  Bill Discount  ${bid}  ${disc1}  
    ${resp}=  Update Bill  ${wid}  ${action[10]}  ${bdisc}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid}  ${action[12]}  ${cupn_code1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${gst_rate}=            Evaluate   ${ser_amount2} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2

    ${ser_total}=           Evaluate   ${ser_amount} + ${ser_amount2}   
    ${ser_amt}=             Evaluate   ${ser_total} - ${disc_amount}
    ${net_tot}=             Evaluate   ${ser_total} + ${item_amount}
    ${net_total}=           Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amt1}=            Evaluate   ${net_total} - ${coupon_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} + ${item_amount}
    ${total}=               Evaluate   ${net_total} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amt1} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${net_rate1}=           Evaluate   ${net_rate1} + ${gst_rate1}
    ${net_rate1}=           Evaluate   ${net_rate1} - ${jaldee_amt}

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${net_tot}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=${ser_amount2}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}     
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['GSTpercentage']}   ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}         ${ser_amount2} 

JD-TC-JDN Highlevel-4
	[Documentation]  Enable JDN and create bill,disable JDN,recalculate bill and check for JDN. 
    comment          Create bill for another consumer and check bill for JDN

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

        ${subdomain}=  Get Billable Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Test Variable   ${subdomain}
        Exit For Loop IF    '${subdomain}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Y}=  Evaluate  ${PUSERNAME}+5530      
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_Y}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Y}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Y}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Y}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_Y}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Y}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+1505
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+1506
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.ynwtest@netvarth.com
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
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
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_Y}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${p_id}   ${firstname}  ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   1s
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid11}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid12}  ${resp.json()}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid11}   ${resp.json()[0]['id']} 

    ${capacity}=   Random Int   min=20   max=100
    ${parallel}=   Random Int   min=1   max=2
    ${sTime}=  add_timezone_time  ${tz}  0  30  
    ${eTime}=  add_timezone_time  ${tz}  3  00  
    ${queue1}=   FakerLibrary.word
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid11}  ${sid11}   ${sid12}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid11}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    ${c_note}=   FakerLibrary.word
    Set Suite Variable   ${c_note}
    ${resp}=  Add To Waitlist  ${cid}  ${sid11}  ${qid11}  ${DAY}  ${c_note}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid1[0]}

    ${total}=   Evaluate   ${ser_amount} * ${jdn_disc_percentage[0]}
    ${net_rate}=   Evaluate    ${total} / 100  
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}     2

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid11}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}

    ${resp}=   Disable JDN
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${servicecharge}=   Evaluate   ${ser_amount} + ${ser_amount1}
    ${total}=   Evaluate   ${servicecharge} * ${jdn_disc_percentage[0]}
    ${net_rate}=   Evaluate    ${total} / 100  
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${servicecharge} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}     2
    ${reason}=  FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid12}   1 
    ${resp}=  Update Bill  ${wid1}  ${action[0]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${servicecharge}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid11}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}       ${sid12}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}     ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}           ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}         ${ser_amount1}

    ${resp}=  Add To Waitlist  ${cid}  ${sid12}  ${qid11}  ${DAY}  ${c_note}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amount1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${ser_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${ser_amount1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid12}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount1}

JD-TC-JDN Highlevel-5
	[Documentation]  Enable JDN and check bill for family member.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid2}  ${resp.json()[0]['id']}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${resp}=  AddFamilyMemberByProvider  ${cid2}  ${f_name}  ${l_name}  ${dob}  ${Genderlist[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_id}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid2}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${mem_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${total}=         Evaluate   ${ser_amount} * ${jdn_disc_percentage[0]}
    ${total}=         Convert To Number   ${total}   2
    ${net_rate}=      Evaluate    ${total} / 100  
    ${net_rate}=      Convert To Number   ${net_rate}   2
    ${amount}=        Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=     Evaluate   ${ser_amount} - ${amount}
    ${net_rate1}=     Convert To Number   ${net_rate1}     2

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}

JD-TC-JDN Highlevel-6
	[Documentation]  Enable JDN and check bill after removing provider discount, provider coupon, Jaldee Coupon and item from taxable services.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  AddCustomer  ${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    # ${cid1}=  get_id  ${CUSERNAME9}
    # Set Suite Variable  ${cid1}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${coupon_amount}=  Set Variable    10.0
    ${cupn_code2}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=150
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid1}   ${sid2}  ${sid3}
    ${items}=  Create List   ${item_id}
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${coupon_amount}  ${calctype[1]}  ${cupn_code2}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  items=${items}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${coupon_id}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid1}  ${sid3}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    
    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid}  ${action[12]}  ${cupn_code2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${net_total}=           Evaluate   ${ser_amount2} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount2} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amt1} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${final_amount}=        Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount1}=        Convert To Number   ${final_amount}   2
    ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}      
    
    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid}  ${action[7]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${bid}  ${resp.json()['id']}
    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid}  ${action[13]}  ${cupn_code2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid}  ${action[5]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Jaldee Coupon By Provider  ${cupn_code} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2
    ${final_amount}=   Evaluate   ${final_amount} - ${jaldee_amt}

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2}

JD-TC-JDN Highlevel-7
	[Documentation]  Update JDN and check bill after applying provider discount, provider coupon, Jaldee Coupon and item to non taxable services.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code    ${cupn_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add To Waitlist  ${cid2}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${disc_max}=   Random Int   min=200   max=400
    Set Suite Variable   ${disc_max}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total}=   Evaluate   ${ser_amount} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount} - ${amount}
    # ${net_rate1}=  Convert To Number   ${net_rate1}   2
    # ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    # ${gst_rate}=   Convert To Number   ${gst_rate}  2
    # ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    # ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    # ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    # ${final_amount}=  Convert To Number   ${final_amount}   2
    ${final_amount}=  Convert To Number   ${net_rate1}   2



    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid1}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid1}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid1}  ${action[12]}  ${cupn_code1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid1}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${net_total}=           Evaluate   ${ser_amount} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amt1} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    # ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    # ${gst_rate}=            Convert To Number   ${gst_rate}  2
    # ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    # ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${final_amount}=        Evaluate   ${net_rate1} + 0.0
    ${final_amount1}=        Convert To Number   ${final_amount}   2
    ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}  



JD-TC-JDN Highlevel-8
	[Documentation]  Update JDN and check bill after applying provider discount, provider coupon, Jaldee Coupon and item to taxable services.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  AddCustomer  ${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid2}  ${sid3}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid8}  ${wid[0]}

    ${resp}=  Get Bill By UUId  ${wid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    
    ${disc_max}=   Random Int   min=200   max=400
    Set Suite Variable   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[1]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2

    ${resp}=  Get Bill By UUId  ${wid8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid8}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid8}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    
    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid8}  ${action[12]}  ${cupn_code1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid8}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${net_total}=           Evaluate   ${ser_amount2} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount2} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amt1} * ${jdn_disc_percentage[1]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${final_amount}=        Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount1}=        Convert To Number   ${final_amount}   2
    ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    ${resp}=  Get Bill By UUId  ${wid8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid8}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}  


JD-TC-JDN Highlevel-9
	[Documentation]  Update JDN and check bill after adding taxable service, provider discount, provider coupon, Jaldee Coupon and item to non taxable service bill.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid2}  ${resp.json()[0]['id']} 

    ${resp}=  Add To Waitlist  ${cid2}  ${sid3}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid9}  ${wid[0]}
    
    ${disc_max}=   Random Int   min=200   max=400
    Set Suite Variable   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2

    ${resp}=  Get Bill By UUId  ${wid9}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid9}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2}



    # ${resp}=  Get Bill By UUId  ${wid9}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Log  ${resp.json()}
    # Set Test Variable  ${bid}  ${resp.json()['id']}
    # Verify Response  ${resp}  uuid=${wid9}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=0.0  totalTaxAmount=0.0
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid1}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    # Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    # Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    0.0
    # Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}


    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid2}   1   
    ${resp}=  Update Bill  ${wid9}  ${action[0]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=   FakerLibrary.word
    ${disc1}=  Bill Discount Input  ${disc_id}  ${reason}   ${reason}
    ${bdisc}=  Bill Discount  ${bid}  ${disc1}  
    ${resp}=  Update Bill  ${wid9}  ${action[10]}  ${bdisc}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid9}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid9}  ${action[12]}  ${cupn_code1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid9}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${gst_rate}=            Evaluate   ${ser_amount1} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2

    ${ser_total}=           Evaluate   ${ser_amount1} + ${ser_amount2}   
    ${ser_amt}=             Evaluate   ${ser_total} - ${disc_amount}
    ${net_total}=           Evaluate   ${ser_total} + ${item_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} - ${coupon_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} + ${item_amount}
    ${ser_amt11}=           Evaluate   ${net_total} - ${disc_amount}
    ${total}=               Evaluate   ${ser_amt11} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${net_rate1}=           Evaluate   ${net_rate1} + ${gst_rate1}
    ${net_rate1}=           Evaluate   ${net_rate1} - ${jaldee_amt}

    ${resp}=  Get Bill By UUId  ${wid9}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid9}  netTotal=${net_total}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=${ser_amount2}  totalTaxAmount=${gst_rate1}
           
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2} 

    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}       ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}     ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}           ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}         ${ser_amount1}

  

JD-TC-JDN Highlevel-10
	[Documentation]  Enable JDN and  apply provider discount, provider coupon, Jaldee Coupon and item to taxable services and update JDN, check bill.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid2}  ${sid3}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid10}  ${wid[0]}
    
    ${disc_max}=   Random Int   min=200   max=400
    Set Suite Variable   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2

    ${resp}=  Get Bill By UUId  ${wid10}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid10}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid10}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid10}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid10}  ${action[12]}  ${cupn_code1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid10}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${net_total}=           Evaluate   ${ser_amount2} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount2} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amt1} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${final_amount}=        Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount1}=        Convert To Number   ${final_amount}   2
    ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    ${resp}=  Get Bill By UUId  ${wid10}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid10}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}  




JD-TC-JDN Highlevel-11
	[Documentation]  Enable JDN and apply provider discount, provider coupon, Jaldee Coupon and item to non taxable services and update JDN, check bill.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  AddCustomer  ${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid2}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid11}  ${wid[0]}
    
    ${disc_max}=   Random Int   min=200   max=400
    Set Suite Variable   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total}=   Evaluate   ${ser_amount} * ${jdn_disc_percentage[1]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    # ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    # ${gst_rate}=   Convert To Number   ${gst_rate}  2
    # ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    # ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + 0.0
    ${final_amount}=  Convert To Number   ${final_amount}   2

    ${resp}=  Get Bill By UUId  ${wid11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid11}  netTotal=${ser_amount}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid1}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid11}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid11}  ${action[12]}  ${cupn_code1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid11}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${net_total}=           Evaluate   ${ser_amount} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amt1} * ${jdn_disc_percentage[1]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    # ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    # ${gst_rate}=            Convert To Number   ${gst_rate}  2
    # ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    # ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${final_amount}=        Evaluate   ${net_rate1} + 0.0
    ${final_amount1}=        Convert To Number   ${final_amount}   2
    ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    ${resp}=  Get Bill By UUId  ${wid11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid11}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}  



JD-TC-JDN Highlevel-12
	[Documentation]  Enable JDN and add taxable service, provider discount, provider coupon, Jaldee Coupon and item to non taxable service bill and update JDN, check bill.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  AddCustomer  ${CUSERNAME14}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid2}  ${sid2}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid12}  ${wid[0]}
    
    ${disc_max}=   Random Int   min=200   max=400
    Set Suite Variable   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${total}=         Evaluate   ${ser_amount1} * ${jdn_disc_percentage[0]}
    ${total}=         Convert To Number   ${total}   2
    ${net_rate}=      Evaluate    ${total} / 100  
    ${net_rate}=      Convert To Number   ${net_rate}   2
    ${amount}=        Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=     Evaluate   ${ser_amount1} - ${amount}
    ${net_rate1}=     Convert To Number   ${net_rate1}     2

    ${resp}=  Get Bill By UUId  ${wid12}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid12}  netTotal=${ser_amount1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount1}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1   
    ${resp}=  Update Bill  ${wid12}  ${action[0]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=   FakerLibrary.word
    ${disc1}=  Bill Discount Input  ${disc_id}  ${reason}   ${reason}
    ${bdisc}=  Bill Discount  ${bid}  ${disc1}  
    ${resp}=  Update Bill  ${wid12}  ${action[10]}  ${bdisc}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid12}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid12}  ${action[12]}  ${cupn_code1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid12}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${gst_rate}=            Evaluate   ${ser_amount2} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2

    ${ser_total}=           Evaluate   ${ser_amount1} + ${ser_amount2}   
    ${ser_amt}=             Evaluate   ${ser_total} - ${disc_amount}
    ${net_total}=           Evaluate   ${ser_total} + ${item_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} - ${coupon_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} + ${item_amount}
    ${ser_amt11}=           Evaluate   ${net_total} - ${disc_amount}
    ${total}=               Evaluate   ${ser_amt11} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${net_rate1}=           Evaluate   ${net_rate1} + ${gst_rate1}
    ${net_rate1}=           Evaluate   ${net_rate1} - ${jaldee_amt}

    ${resp}=  Get Bill By UUId  ${wid12}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid12}  netTotal=${net_total}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${net_rate1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${net_rate1}  taxableTotal=${ser_amount2}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount1}     
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['GSTpercentage']}   ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}         ${ser_amount2} 


    # ${total}=   Evaluate   ${ser_amount1} * ${jdn_disc_percentage[0]}
    # ${total}=   Convert To Number   ${total}    2
    # ${net_rate}=   Evaluate    ${total} / 100  
    # ${net_rate}=  Convert To Number   ${net_rate}   2
    # ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    # ${net_rate1}=   Evaluate   ${ser_amount1} - ${amount}
    # ${net_rate1}=  Convert To Number   ${net_rate1}   2
    # # ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    # # ${gst_rate}=   Convert To Number   ${gst_rate}  2
    # # ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    # # ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    # # ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    # ${final_amount}=   Evaluate   ${net_rate1} + 0.0
    # ${final_amount}=  Convert To Number   ${final_amount}   2


    # ${resp}=  Get Bill By UUId  ${wid12}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Log  ${resp.json()}
    # Set Test Variable  ${bid}  ${resp.json()['id']}
    # Verify Response  ${resp}  uuid=${wid12}  netTotal=${ser_amount1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=0.0  totalTaxAmount=0.0
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid2}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE2} 
    # Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    # # Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    0.0
    # Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount1}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount1}

    # ${reason}=   FakerLibrary.word
    # ${service}=  Service Bill  ${reason}  ${sid3}   1    ${disc_id}
    # ${resp}=  Update Bill  ${wid12}  ${action[6]}  ${service}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200 

    # ${resp}=  Get Bill By UUId  ${wid12}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${bid}  ${resp.json()['id']}
    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    # ${resp}=  Update Bill  ${wid12}  ${action[12]}  ${coupon}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200 

    # ${reason}=  FakerLibrary.word
    # ${service}=  Item Bill   ${reason}  ${item_id}  1
    # ${resp}=  Update Bill  ${wid12}  ${action[3]}  ${service}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid12}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${net_total}=           Evaluate   ${ser_amount2} + ${item_amount}
    # ${ser_amt}=             Evaluate   ${ser_amount2} - ${disc_amount}
    # ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    # ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    # ${total}=               Evaluate   ${ser_amount_total} * ${jdn_disc_percentage[0]}
    # ${total}=               Convert To Number   ${total}   2
    # ${net_rate}=            Evaluate    ${total} / 100  
    # ${net_rate}=            Convert To Number   ${net_rate}   2
    # ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    # ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    # ${net_rate1}=           Convert To Number   ${net_rate1}     2
    # ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    # ${gst_rate}=            Convert To Number   ${gst_rate}  2
    # ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    # ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    # ${final_amount}=        Evaluate   ${net_rate1} + ${gst_rate1}
    # ${final_amount1}=        Convert To Number   ${final_amount}   2
    # ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    # ${resp}=  Get Bill By UUId  ${wid12}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Log  ${resp.json()}
    # Set Test Variable  ${bid}  ${resp.json()['id']}
    # Verify Response  ${resp}  uuid=${wid12}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=0.0  totalTaxAmount=0.0
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    # Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    # Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}  
   
   


*** comment ***
JD-TC-JDN Highlevel-7
	[Documentation]  Update JDN and check bill after applying provider discount, provider coupon, Jaldee Coupon and item to non taxable services.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Add To Waitlist  ${cid2}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${disc_max}=   Random Int   min=200   max=400
    Set Suite Variable   ${disc_max}
    ${d_note}=   FakerLibrary.word
    Set Suite Variable   ${d_note}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid1}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid1}  ${action[12]}  ${coupon}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid1}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${net_total}=           Evaluate   ${ser_amount2} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount2} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amount_total} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${final_amount}=        Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount1}=        Convert To Number   ${final_amount}   2
    ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}  


JD-TC-JDN Highlevel-8
	[Documentation]  Update JDN and check bill after applying provider discount, provider coupon, Jaldee Coupon and item to taxable services.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  AddCustomer  ${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid2}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${disc_max}=   Random Int   min=200   max=400
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid1}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid1}  ${action[12]}  ${coupon}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid1}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${net_total}=           Evaluate   ${ser_amount2} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount2} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amount_total} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${final_amount}=        Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount1}=        Convert To Number   ${final_amount}   2
    ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}  


JD-TC-JDN Highlevel-9
	[Documentation]  Update JDN and check bill after adding taxable service, provider discount, provider coupon, Jaldee Coupon and item to non taxable service bill.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']} 

    ${resp}=  Add To Waitlist  ${cid2}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${disc_max}=   Random Int   min=200   max=400
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid1}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid1}  ${action[12]}  ${coupon}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid1}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${net_total}=           Evaluate   ${ser_amount2} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount2} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amount_total} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${final_amount}=        Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount1}=        Convert To Number   ${final_amount}   2
    ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}  

JD-TC-JDN Highlevel-10
	[Documentation]  Enable JDN and  apply provider discount, provider coupon, Jaldee Coupon and item to non taxable services and update JDN, check bill.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid2}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${disc_max}=   Random Int   min=200   max=400
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid1}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid1}  ${action[12]}  ${coupon}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid1}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${net_total}=           Evaluate   ${ser_amount2} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount2} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amount_total} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${final_amount}=        Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount1}=        Convert To Number   ${final_amount}   2
    ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}  

JD-TC-JDN Highlevel-11
	[Documentation]  Enable JDN and apply provider discount, provider coupon, Jaldee Coupon and item to taxable services and update JDN, check bill.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid2}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${disc_max}=   Random Int   min=200   max=400
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid1}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid1}  ${action[12]}  ${coupon}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid1}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${net_total}=           Evaluate   ${ser_amount2} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount2} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amount_total} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${final_amount}=        Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount1}=        Convert To Number   ${final_amount}   2
    ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}  

JD-TC-JDN Highlevel-12
	[Documentation]  Enable JDN and add taxable service, provider discount, provider coupon, Jaldee Coupon and item to non taxable service bill and update JDN, check bill.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid2}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${disc_max}=   Random Int   min=200   max=400
    Set Suite Variable   ${disc_max}
    ${resp}=   Update JDN with Percentage    ${d_note}  ${jdn_disc_percentage[1]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total}=   Evaluate   ${ser_amount2} * ${jdn_disc_percentage[0]}
    ${total}=   Convert To Number   ${total}    2
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}   2
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount2} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}   2
    ${gst_rate}=   Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=   Convert To Number   ${gst_rate}  2
    ${gst_rate1}=   Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=  Convert To Number   ${gst_rate1}    2
    ${final_amount}=   Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount}=  Convert To Number   ${final_amount}   2

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstpercentage[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amount2}

    ${reason}=   FakerLibrary.word
    ${service}=  Service Bill  ${reason}  ${sid3}   1    ${disc_id}
    ${resp}=  Update Bill  ${wid1}  ${action[6]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${wid1}  ${action[12]}  ${coupon}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${reason}=  FakerLibrary.word
    ${service}=  Item Bill   ${reason}  ${item_id}  1
    ${resp}=  Update Bill  ${wid1}  ${action[3]}  ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${net_total}=           Evaluate   ${ser_amount2} + ${item_amount}
    ${ser_amt}=             Evaluate   ${ser_amount2} - ${disc_amount}
    ${ser_amt1}=            Evaluate   ${ser_amt} + ${item_amount}
    ${ser_amount_total}=    Evaluate   ${ser_amt1} - ${coupon_amount}
    ${total}=               Evaluate   ${ser_amount_total} * ${jdn_disc_percentage[0]}
    ${total}=               Convert To Number   ${total}   2
    ${net_rate}=            Evaluate    ${total} / 100  
    ${net_rate}=            Convert To Number   ${net_rate}   2
    ${amount}=              Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=           Evaluate   ${ser_amount_total} - ${amount}
    ${net_rate1}=           Convert To Number   ${net_rate1}     2
    ${gst_rate}=            Evaluate   ${net_rate1} * ${gstpercentage[1]}
    ${gst_rate}=            Convert To Number   ${gst_rate}  2
    ${gst_rate1}=           Evaluate    ${gst_rate} / 100 
    ${gst_rate1}=           Convert To Number   ${gst_rate1}    2
    ${final_amount}=        Evaluate   ${net_rate1} + ${gst_rate1}
    ${final_amount1}=        Convert To Number   ${final_amount}   2
    ${final_amount1}=       Evaluate   ${final_amount1} - ${jaldee_amt}


    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amt1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${final_amount1}  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${final_amount1}  taxableTotal=${net_rate1}  totalTaxAmount=${gst_rate1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}       ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}     ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}        1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}           ${ser_amount2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}         ${ser_amt}  
   
# JD-TC-JDN Time-1
#     [Documentation]  Check JDN for future checkin.

# JD-TC-JDN Time-2
#     [Documentation]  Enable JDN, Create bill and check bill history.


***Keywords***

Get Non Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[0]}'
    END
    [Return]  ${subdomain}  ${resp.json()['serviceBillable']}
