*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Finance Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***
${service_duration}     30
@{emptylist}

${SERVICE1}  Note Book1102
${SERVICE2}  boots102
${SERVICE3}  pen102
${SERVICE5}  boots13101
${queue1}  morning
${LsTime}   08:00 AM
${LeTime}   09:00 AM

${sTime}    09:00 PM
${eTime}    11:00 PM
${longi}        89.524764
${latti}        86.524764
${Coupon19}     Coupon1912



*** Test Cases ***

JD-TC-Apply JaldeeCoupon-1

    [Documentation]  Apply Jaldee coupon to invoice.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${d1}  ${resp.json()['serviceSector']['domain']}
    Set Suite Variable  ${sd1}  ${resp.json()['serviceSubSector']['subDomain']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    Set Suite Variable  ${licid}  ${resp.json()['licensePkgID']}



    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=   Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END


    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp1.json()}
 
     
    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}


    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}


 
    ${sTime}=   db.add_timezone_time     ${tz}  1  00
    Set Suite Variable    ${sTime}
    ${eTime}=    db.add_timezone_time     ${tz}  3  00 
    Set Suite Variable    ${eTime}   

    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}.${test_mail}
    ${address}=  FakerLibrary.city
    Set Suite Variable  ${address}
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    ${branch}=   db.get_place
    ${ifsc_code}=   db.Generate_ifsc_code
    # ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state}
    Set Suite Variable    ${district}
    Set Suite Variable    ${pin}
    ${vendor_phno}=   Create List  ${vendor_phno}
    Set Suite Variable    ${vendor_phno}
    
    ${email}=   Create List  ${email}
    Set Suite Variable    ${email}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc} 

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    ${upiId}     FakerLibrary.name
    Set Suite Variable  ${upiId}

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}

    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}
    
    ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
    ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=    Create List         ${bankInfo}
    


    ${resp1}=  AddCustomer  ${CUSERNAME11}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}


    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Suite Variable  ${providerConsumerIdList} 

    ${SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    # ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}    department=${dep_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sid1}  ${resp.json()} 


    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[1]}   department=${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()} 

    ${domains}=  Jaldee Coupon Target Domains  ${d1} 
    Set Suite Variable   ${domains} 
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1} 
    Set Suite Variable   ${sub_domains}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    Set Suite Variable   ${licenses}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=   db.add_timezone_date  ${tz}  10     
    Set Suite Variable  ${DAY2}  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code2023}=    FakerLibrary.word
    ${Jamount1}=    Random Int   min=10  max=50
    ${Jamount1}=  Convert To Number  ${Jamount1}  1
    ${cupn_name}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    clear_jaldeecoupon  ${cupn_code2023}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2023}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  ${Jamount1}  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2023}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2023}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2023}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2023}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1
    ${invoiceId}=   FakerLibrary.word

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${serviceprice}=   Random Int  min=1000  max=1500
    ${serviceprice}=  Convert To Number  ${serviceprice}  1

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}  price=${serviceprice}
    ${serviceList}=    Create List    ${serviceList}
    
    
    ${resp}=  Create Invoice   ${category_id2}   ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]} 


    ${resp}=   Apply Jaldee Coupon   ${invoice_uid}   ${cupn_code2023}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCoupons'][0]['couponCode']}  ${cupn_code2023}
    Should Be Equal As Strings  ${resp.json()['jaldeeCoupons'][0]['discount']}  ${Jamount1}
    Should Be Equal As Strings  ${resp.json()['jaldeeCoupons'][0]['date']}  ${DAY1}

# JD-TC-Apply ProviderCoupon-2

#     [Documentation]  Create a invoice and assign the invoice to a user then unassign that user.

#     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${privateNote}=     FakerLibrary.word
#     ${displayNote}=   FakerLibrary.word


#     ${resp}=   Apply Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}
#     Log  ${resp.json()}
#     Set Test Variable   ${discountId1}   ${resp.json()}   
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Remove Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}
#     Log  ${resp.json()}
#     Set Suite Variable   ${rmvid}   ${resp.json()}   
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Invoice By Id  ${invoice_uid}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

# *** Comments ***
JD-TC-ApplyJaldeeCoupon-2
    [Documentation]    Provider trying to apply default enabled coupon

    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code03}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code03}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.name

    ${Jamount1}=    Random Int   min=10  max=50
    ${Jamount1}=  Convert To Number  ${Jamount1}  1
    ${cupn_name}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}

    clear_jaldeecoupon  ${cupn_code03}
    ${resp}=  Create Jaldee Coupon  ${cupn_code03}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  100  100  ${bool[1]}  ${bool[0]}  0  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code03}  ${cupn_name}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code03}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}


    ${SERVICE1}=    FakerLibrary.name
    ${description}=    FakerLibrary.name

    # ${resp}=  Create Service  ${SERVICE1}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[1]}  ${bool[1]}  department=${dep_id}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${s_id1}  ${resp.json()}


    ${resp}=  Create Service  ${SERVICE1}  ${description}   2  ${bool[0]}  50  ${bool[1]}   department=${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()} 
    
    ${queue1}=    FakerLibrary.name
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_id1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    

    ${resp}=  Auto Invoice Generation For Service   ${s_id1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()}
    # ${cid}=  get_id  ${CUSERNAME3}
    ${des}=   FakerLibrary.sentence
    Set Suite Variable   ${des}
    ${resp}=  Add To Waitlist  ${id}  ${s_id1}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    sleep  02s
    ${resp1}=  Get Booking Invoices  ${wid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${invoice_appt_uid}  ${resp1.json()[0]['invoiceUid']}

    ${resp}=  Get Invoice By Id  ${invoice_appt_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By UUId  ${wid}
    # Log  ${resp.json()} 
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    # Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    # Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    # Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    # Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0


    ${resp}=   Apply Jaldee Coupon   ${invoice_appt_uid}   ${cupn_code03}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Invoice By Id  ${invoice_appt_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By UUId  ${wid}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code03}']['value']}  100.0
    # Should Contain  ${resp.json()['jCoupon']['${cupn_code03}']['systemNote']}  ${SystemNote[1]}
    # Should Contain  ${resp.json()['jCoupon']['${cupn_code03}']['systemNote']}  ${SystemNote[2]}
    # Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    # Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    # Should Be Equal As Strings  ${resp.json()['netRate']}   472.0
    # Should Be Equal As Strings  ${resp.json()['amountDue']}  472.0

    # ${resp}=  Accept Payment  ${wid}  ${acceptPaymentBy[0]}  472.0
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Get Payment By UUId  ${wid}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    # Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${acceptPaymentBy[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['amount']}  472.0

    # ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code03}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  100.0
    # Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    # Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0


JD-TC-ApplyJaldeeCoupon-3
    [Documentation]    Provider trying to apply always enabled coupon (Taxable is false)

    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    ${locations}=  Create List  ${loc1}  ${loc2}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code04}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code04}
    ${cupn_name}=   FakerLibrary.word
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.word
    ${c_des}=   FakerLibrary.word
    ${p_des}=   FakerLibrary.word

    clear_jaldeecoupon  ${cupn_code04}
    ${resp}=  Create Jaldee Coupon  ${cupn_code04}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[1]}  ${bool[1]}  0  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code04}  ${cupn_name}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code04}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id1}  ${resp.json()}
    # ${cid}=  get_id  ${CUSERNAME1}
    ${resp}=  Add To Waitlist  ${id1}  ${s_id1}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    sleep  02s
    ${resp1}=  Get Booking Invoices  ${wid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${invoice_appt_uid}  ${resp1.json()[0]['invoiceUid']}

    ${resp}=  Get Invoice By Id  ${invoice_appt_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By UUId  ${wid}
    # Log  ${resp.json()} 
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    # Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    # Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    # Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    # Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0


    ${resp}=   Apply Jaldee Coupon   ${invoice_appt_uid}   ${cupn_code03}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_appt_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200












































*** Comments ***
JD-TC-Apply ProviderCoupon-2
	[Documentation]  Create two jaldee coupons and provider coupons and apply in a bill and also add discount
    
    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()[0]['id']}

    ${resp}=  Auto Invoice Generation For Service   ${sid1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    Sleep  2s
    ${list}=  Create List  1  2  3  4  5  6  7
    ${capacity}=   Random Int   min=20   max=100
    ${parallel}=   Random Int   min=1   max=2
    ${sTime}=  add_timezone_time  ${tz}  0  43  
    ${eTime}=  add_timezone_time  ${tz}  0  55  
    ${queue1}=    FakerLibrary.name

    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid1}  ${sid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}   ${resp.json()}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
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
    clear_jaldeecoupon  ${jcoupon1}

    ${resp}=   Create Jaldee Coupon   ${jcoupon1}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Jaldee Coupon   ${jcoupon2}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  20  600  ${bool[0]}  ${bool[0]}  100  100  1000  20  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${des1}=    FakerLibrary.Word
    ${resp}=  Push Jaldee Coupon  ${jcoupon1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${des2}=    FakerLibrary.Word
    ${resp}=  Push Jaldee Coupon  ${jcoupon2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_customer   ${HLPUSERNAME5}

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${id}  ${resp.json()[0]['id']}


    ${resp}=  Add To Waitlist  ${id}  ${sid1}  ${q1_l1}  ${DAY}  hi  ${bool[1]}  ${id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount1}   billStatus=New  billViewStatus=Notshow    billPaymentStatus=NotPaid  totalAmountPaid=0.0    taxableTotal=${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount1}

    Comment  Apply JC 
    ${resp}=  Get Jaldee Coupons By Coupon_code   ${jcoupon1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${jcoupon1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${jcoupon1}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount1}   billStatus=New  billViewStatus=Notshow   billPaymentStatus=NotPaid  totalAmountPaid=0.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED

    # Comment  Apply Provider Coupon
    # ${des1}=   FakerLibrary.sentence
    # ${pc_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${resp}=  Create Coupon  ${coupon}  ${des1}  ${pc_amount}   ${calctype[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${couponId}  ${resp.json()}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
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
    ${services}=   Create list   ${sid1}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${bid}  ${resp.json()['id']}
    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill   ${wid1}  addProviderCoupons   ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount1}   billStatus=New  billViewStatus=Notshow    billPaymentStatus=NotPaid  totalAmountPaid=0.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code}']['value']}  ${pc_amount}  
     

    Comment  Apply Discount on service

    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${disc_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${resp}=   Create Discount  ${discount}   ${desc}    ${disc_amount}   ${calctype[1]}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${discountId}   ${resp.json()}
    ${service}=  Service Bill  service forme  ${sid1}  1  ${discountId}
    ${resp}=  Update Bill   ${wid1}  addServiceLevelDiscount   ${service}  
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${netTotal1}=   Evaluate   ${ser_amount1}-${disc_amount}
    ${netTotal2}=   Evaluate   ${netTotal1}-${pc_amount}
    ${taxamnt}=     Evaluate   ${netTotal2}*${gstper}/100
    ${taxamnt}=  Convert To Number  ${taxamnt}  2
    ${netrate1}=   Evaluate  ${netTotal2}+${taxamnt}
    ${netrate2}=    Evaluate  ${netrate1}-50.0
    ${netrate2}=  Convert To Number  ${netrate2}  2

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${netTotal1}   billStatus=New  billViewStatus=Notshow    billPaymentStatus=NotPaid  totalAmountPaid=0.0   amountDue=${netrate2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED
    # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['id']}  ${couponId}  
    # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['couponValue']}  ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code}']['value']}  ${pc_amount}  
    
    Should Be Equal As Strings  ${resp.json()['service'][0]['discount'][0]['id']}  ${discountId}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['discount'][0]['discountValue']}  ${disc_amount}  

    sleep  02s
    ${resp1}=  Get Booking Invoices  ${wid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${invoice_waitlist_uid}  ${resp1.json()[0]['invoiceUid']}

    ${resp}=   Apply Jaldee Coupon   ${invoice_waitlist_uid}   ${cupn_code2023}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_waitlist_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeCoupons'][0]['couponCode']}  ${cupn_code2023}
    Should Be Equal As Strings  ${resp.json()['jaldeeCoupons'][0]['discount']}  ${Jamount1}
    Should Be Equal As Strings  ${resp.json()['jaldeeCoupons'][0]['date']}  ${DAY1}

*** Comments ***
JD-TC-Apply ProviderCoupon-3

    [Documentation]   using jaldee coupon in different payment status with adding service quantity
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Jaldee Coupon By Provider  ${jcoupon2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${jcoupon2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${id}  ${sId_3}  ${q1_l1}  ${DAY}  hi  ${bool[1]}  ${id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ser_amount3}  billStatus=New  billViewStatus=Notshow   billPaymentStatus=NotPaid  totalAmountPaid=0.0   
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ser_amount3}

    ${service}=  Service Bill  service forme  ${sId_3}  ${qnty}
    # ${ammt}=   Evaluate   ${ser_amount3}*${qnty}
    # ${taxamnt}=  Convert To Number  ${ammt}  2
    ${resp}=  Update Bill   ${wid1}  adjustService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ammt}=   Evaluate   ${ser_amount3}*${qnty}
    ${taxamnt}=  Convert To Number  ${ammt}  2
    ${taxamnt1}=   Evaluate   ${taxamnt}*${gstper}/100
    ${taxamnt2}=  Convert To Number  ${taxamnt1}  2
    ${netRate}=   Evaluate  ${ammt}+${taxamnt2}
    ${netRate1}=   Evaluate  ${netRate}-600.0

    

    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ammt}  billStatus=New  billViewStatus=Notshow    billPaymentStatus=NotPaid  totalAmountPaid=0.0  taxableTotal=${ammt}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}   ${qnty}
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ammt}

    Comment  Apply JC 

    ${resp}=  Apply Jaldee Coupon By Provider  ${jcoupon2}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ammt}  billStatus=New  billViewStatus=Notshow    billPaymentStatus=NotPaid  totalAmountPaid=0.0    taxableTotal=${ammt} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  ${qnty}
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ammt}
    Should Contain  ${resp.json()['jCoupon']['${jcoupon2}']['systemNote']}  COUPON_APPLIED


    ${amountDue1}=   Evaluate   ${taxamnt}*10/100
    ${amountDue}=  Convert To Number  ${amountDue1}  2

    ${resp}=  Accept Payment  ${wid1}  ${acceptPaymentBy[0]}   ${amountDue}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid1}  netTotal=${ammt}  billStatus=New  billViewStatus=Show    billPaymentStatus=PartiallyPaid     taxableTotal=${ammt}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  ${qnty}
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}    ${gstper}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${ser_amount3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${ammt}
    Should Contain  ${resp.json()['jCoupon']['${jcoupon2}']['systemNote']}  COUPON_APPLIED

JD-TC-Apply ProviderCoupon-4  
    [Documentation]  Create bill for having taxable service and non taxable service and 100% reiumbursement coupon applied and coupon amount is more than non taxable service amount          
    
    ${description}=  FakerLibrary.sentence
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${bool[1]}    Random Element     ['${bool[1]}','${bool[0]}']
    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Jaldee Coupon  Onam2023  Onam Coupon  Onam offer  CHILDREN  ${DAY1}  ${DAY2}  AMOUNT  500  500  ${bool[0]}  ${bool[0]}  100  500  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  consumer first use  500 offer  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  Onam2023  Onam Coupon Offer
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Tax Percentage  18  12DEFBV1100I7Z2
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid4}=  get_id  ${CUSERNAME6}
    Set Suite Variable  ${cid4}
    ${resp}=  Add To Waitlist  ${cid4}  ${sid1}  ${qid1}  ${DAY1}  hi  ${bool[1]}  ${cid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Verify Response  ${resp}  uuid=${wid}  netTotal=500.0  billStatus=New  billViewStatus=Notshow  netRate=590.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=590.0  taxableTotal=500.0  totalTaxAmount=90.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill  nontaxable  ${sid3}  1
    ${resp}=  Update Bill  ${wid}  addService   ${service}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=800.0  billStatus=New  billViewStatus=Notshow  netRate=890.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=890.0  taxableTotal=500.0  totalTaxAmount=90.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}  300.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}  300.0
    ${service}=  Service Bill   discount   ${sid1}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service} 
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill   discount   ${sid3}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service} 
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  Onam2023
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  NEW
    ${resp}=  Enable Jaldee Coupon By Provider  Onam2023
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  Onam2023
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  Onam2023  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['Onam2023']['value']}  500.0
    Should Contain  ${resp.json()['jCoupon']['Onam2023']['systemNote']}  COUPON_APPLIED
    Verify Response  ${resp}  uuid=${wid}  netTotal=600.0  billStatus=New  billViewStatus=Notshow  netRate=172.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=172.0  taxableTotal=400.0  totalTaxAmount=72.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  400.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}  300.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}  200.0

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  Onam2023
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  500.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0

JD-TC-Apply ProviderCoupon-5   
    [Documentation]  Create bill for having taxable service and non taxable service and 100% reiumbursement coupon applied and coupon amount is more than non taxable service amount then remove non taxable service    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill  service forme  ${sid3}  1 
    ${resp}=  Update Bill   ${wid}  removeService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['Onam2023']['value']}  0.0
    Should Contain  ${resp.json()['jCoupon']['Onam2023']['systemNote']}  MINIMUM_BILL_AMT_REQUIRED
    Verify Response  ${resp}  uuid=${wid}  netTotal=400.0  billStatus=New  billViewStatus=Notshow  netRate=472.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=472.0  taxableTotal=400.0  totalTaxAmount=72.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  400.0
