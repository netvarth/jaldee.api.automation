*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Coupon
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/acc_ver.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***

${SERVICE1}  SERVICE12
${SERVICE2}  SERVICE22
${loc}  Location112
${queue1}  Queue112
${jcoupon1}   CouponMul00
${jcoupon2}   CouponMul02
${coupon1}   Coupon1010
${self}      0

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
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}

*** Test Cases ***

JD-TC-JaldeeCouponAndProviderCoupon-1
	[Documentation]  create bill when parent cancel the waitlist and the bill is created to a member
	
    clear_service  ${PUSERNAME134}
	clear_service  ${PUSERNAME134} 
	clear_location  ${PUSERNAME134}
    clear_Coupon   ${PUSERNAME134}
	clear_jaldeecoupon  ${jcoupon1}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable   ${domain}    ${decrypted_data['sector']}
    Set Suite Variable   ${subDomain}    ${decrypted_data['subSector']}
   
    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${acct_id1}=  get_acc_id  ${PUSERNAME134}
    ${panCardNumber}=  Generate_pan_number
    Set Suite Variable   ${panCardNumber}
    ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
    Set Suite Variable   ${bankAccountNumber}
    ${bankName}=  FakerLibrary.company
    Set Suite Variable   ${bankName}
    ${ifsc}=  Generate_ifsc_code
    Set Suite Variable   ${ifsc}
    ${panname}=  FakerLibrary.name
    Set Suite Variable   ${panname}
    ${firstname}=   FakerLibrary.name
    Set Suite Variable   ${firstname}
    ${city}=   get_place
    Set Suite Variable   ${city}
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME134}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${panname}  ${firstname}  ${city}   ${businessStatus[1]}   ${accounttype[1]}  
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${acct_id1}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME134}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${panname}  ${firstname}  ${city}   ${businessStatus[1]}   ${accounttype[1]}    
    Should Be Equal As Strings    ${resp.status_code}   200


    ${pid}=  get_acc_id  ${PUSERNAME134}
    ${resp}=  SetMerchantId  ${pid}  4825051
    ${pid}=  get_acc_id  ${PUSERNAME134}
    Set Suite Variable  ${pid}
    
    ${gstper}=  Random Element  ${gstpercentage}
    Set Suite Variable    ${gstper}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Tax Percentage 
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()['taxPercentage']}   ${gstper}
    Should Be Equal As Strings   ${resp.json()['gstNumber']}   ${GST_num}

    ${desc}=  FakerLibrary.sentence
    set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount1}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}

    ${desc}=  FakerLibrary.sentence
    set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount2}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount2}
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount2}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}

    ${companySuffix}=  FakerLibrary.companySuffix
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${description}=  FakerLibrary.sentence
    ${snote}=  FakerLibrary.Word
    ${dis}=  FakerLibrary.Word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  30  
    ${eTime}=  add_timezone_time  ${tz}  3  00  

    ${DAY}=  db.get_date_by_timezone  ${tz}   
    Set Suite Variable  ${DAY} 

    ${resp}=  Create Location  ${loc}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}   ${address}  free  True  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid1}  ${resp.json()} 


    ${capacity}=   Random Int   min=20   max=100
    ${parallel}=   Random Int   min=1   max=2
    ${sTime}=  add_timezone_time  ${tz}  0  30  
    ${eTime}=  add_timezone_time  ${tz}  0  45  

    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${parallel}  ${capacity}  ${lid1}  ${sId_1}  ${sId_2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}   ${resp.json()}
  
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    # ${desc}=  FakerLibrary.Sentence   nb_words=2
    # ${cou_amount}=   Random Int   min=1   max=40
    # ${cou_amount}=   Convert To Number   ${cou_amount}
    # Set Suite Variable  ${cou_amount}

    # ${resp}=  Create Coupon  ${coupon1}  ${desc}   ${cou_amount}   ${calctype[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${couponId}  ${resp.json()}
    
    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${cou_amount}=   Random Int   min=1   max=40
    ${cou_amount}=   Convert To Number   ${cou_amount}
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=150
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sId_1}   ${sId_2}
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${cou_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}
    
    clear_FamilyMember  ${pid}
    ${resp}=  AddCustomer  ${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id}  ${resp.json()}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${id}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}

    sleep  02s
    ${resp}=  ListFamilyMemberByProvider  ${id}
    Log  ${resp.json()}
    Verify Response List  ${resp}  0  id=${mem_id}  
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${id}   ${sId_1}  ${q1_l1}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}


    ${resp}=   Create Jaldee Coupon   ${jcoupon1}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=  Push Jaldee Coupon  ${jcoupon1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200 
    comment  1

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill   ${wid}  addProviderCoupons   ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Coupons By Coupon_code   ${jcoupon1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}

    ${resp}=  Enable Jaldee Coupon By Provider  ${jcoupon1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${jcoupon1}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
     sleep  6s
    ${resp}=  Apply Jaldee Coupon By Provider  ${jcoupon1}  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}   ${wid}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}   ${sId_1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}   ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}   ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}   ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code}']['value']}  ${cou_amount}  
    # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['name']}   ${coupon1}
    # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['id']}   ${couponId}
    Should Be Equal As Strings  ${resp.json()['jCouponList'][0]['couponCode']}   ${jcoupon1}


JD-TC-JaldeeCouponAndProviderCoupon-2

    [Documentation]  create Provider coupon and jaldee coupon in appointment case and apply in bill for a taxable service

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+100257301
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    
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
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}
   
    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+100100302
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH1}${\n}
    
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+100100303
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}
    
    ${PUSERMAIL0}=   Set Variable  ${P_Email}${PUSERPH0}.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    Log   ${views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
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
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  30   
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
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

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH0}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}  ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Appointment
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

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  30  
    ${eTime}=  add_timezone_time  ${tz}  3  00  
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${loc}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}


    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${d1}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${d1}_${sd1}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${pid}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${pid}
    ${DAY}=  db.get_date_by_timezone  ${tz}   
    Set Suite Variable  ${DAY} 

    ${gstper}=  Random Element  ${gstpercentage}
    Set Suite Variable    ${gstper}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Tax Percentage 
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()['taxPercentage']}   ${gstper}
    Should Be Equal As Strings   ${resp.json()['gstNumber']}   ${GST_num}

    ${desc}=  FakerLibrary.sentence
    set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=150   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount1}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    # ${desc}=  FakerLibrary.Sentence   nb_words=2
    # ${cou_amount}=   Random Int   min=1   max=40
    # ${cou_amount}=   Convert To Number   ${cou_amount}
    # Set Suite Variable  ${cou_amount}

    # ${resp}=  Create Coupon  ${coupon1}  ${desc}   ${cou_amount}   ${calctype[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${couponId}  ${resp.json()}

    ${coupon1}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${cou_amount}=   Random Int   min=1   max=40
    ${cou_amount}=   Convert To Number   ${cou_amount}
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=150
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sId_1}  
    ${resp}=  Create Provider Coupon   ${coupon1}  ${desc}  ${cou_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    # ${resp}=   Get Appointment Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${result}=  Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment
    # # Log   ${result.json()}
    # Should Be Equal As Strings  ${result.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable   ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}      ${parallel}  ${lid1}  ${duration}  ${bool1}   ${sId_1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}   ${sId_1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}


    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${sId_1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}

    ${coup_value}=    Random Int   min=1   max=40
    ${resp}=   Create Jaldee Coupon   ${jcoupon2}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  ${coup_value}  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=  Push Jaldee Coupon  ${jcoupon2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200 
    comment  1

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${tax}=               Evaluate   (${ser_amount1}*${gstper})/100
    ${amt_due}=           Evaluate    ${tax} + ${ser_amount1}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${apptid1}  netTotal=${ser_amount1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${amt_due}   totalTaxAmount=${tax}

    Set Test Variable  ${bid}  ${resp.json()['id']}
    ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill   ${apptid1}  addProviderCoupons   ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Coupons By Coupon_code   ${jcoupon2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${jcoupon2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${jcoupon2}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${jcoupon2}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${couponreducedamt}=  Evaluate   ${ser_amount1} - ${cou_amount}
    ${tax}=               Evaluate   (${couponreducedamt}*${gstper})/100
    ${total}=             Evaluate    ${tax}+${couponreducedamt}
    ${amt_due}=           Evaluate    ${total} - ${coup_value}
    
    ${resp}=  Get Bill By UUId  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${apptid1}  netTotal=${ser_amount1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}   billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=${amt_due}    totalTaxAmount=${tax}
    