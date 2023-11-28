*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      JDN
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

***Variables***
${SERVICE1}       SERVICE1
${SERVICE2}       SERVICE2

*** Test Cases ***

JD-TC-DisableJDN-1
	[Documentation]  Disable JDN for a valid provider in billable domain

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
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+1480              
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

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable    ${list}
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
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
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
    ${resp}=  Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   1s
    ${disc_max}=   Random Int   min=100.00   max=500.00
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
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
    ${resp}=   Disable JDN
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[0]}
    Should Be Equal As Strings   ${resp.json()['discMax']}          ${disc_max}
    Should Be Equal As Strings   ${resp.json()['status']}           ${Qstate[1]}

JD-TC-DisableJDN-2
	[Documentation]  Disable JDN Percent and check bill

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${desc}=  FakerLibrary.sentence
    set Suite Variable   ${desc}
    ${ser_durtn}=   Random Int   min=2   max=10
    Set Suite Variable   ${ser_durtn}
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount}=   Convert To Number   ${ser_amount}
    Set Suite Variable   ${ser_amount}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${capacity}=   Random Int   min=20   max=100
    ${parallel}=   Random Int   min=1   max=2
    ${sTime}=  add_timezone_time  ${tz}  1  30  
    ${eTime}=  add_timezone_time  ${tz}  3  00  
    ${queue1}=   FakerLibrary.word
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${sid1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${c_note}=   FakerLibrary.word
    Set Suite Variable   ${c_note}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
	${desc}=    FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY}  ${c_note}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${total}=   Evaluate   ${ser_amount} * ${jdn_disc_percentage[0]}
    ${total}=  Convert To Number   ${total}
    ${net_rate}=   Evaluate    ${total} / 100  
    ${net_rate}=  Convert To Number   ${net_rate}
    ${amount}=  Set Variable If  ${net_rate} > ${disc_max}   ${disc_max}   ${net_rate}
    ${net_rate1}=   Evaluate   ${ser_amount} - ${amount}
    ${net_rate1}=  Convert To Number   ${net_rate1}

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

    ${resp}=   Disable JDN
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

JD-TC-DisableJDN-3
	[Documentation]  Check if bill gets updated when JDN is disabled and bill is updated

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
    ${PUSERNAME_Y}=  Evaluate  ${PUSERNAME}+1530      
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
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+1505
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+1506
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
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
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
    ${resp}=  Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
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
    ${ser_amount1}=   Random Int   min=100   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount1}
    Set Suite Variable   ${ser_amount1}
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${ser_durtn}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid12}  ${resp.json()}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid11}   ${resp.json()[0]['id']} 

    ${capacity}=   Random Int   min=20   max=100
    ${parallel}=   Random Int   min=1   max=2
    ${sTime}=  add_timezone_time  ${tz}  1  30  
    ${eTime}=  add_timezone_time  ${tz}  3  00  
    ${queue1}=   FakerLibrary.word
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid11}  ${sid11}   ${sid12}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid11}  ${resp.json()}
    ${c_note}=   FakerLibrary.word
    Set Suite Variable   ${c_note}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
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

JD-TC-DisableJDN-4
	[Documentation]  Disable a JDN for a valid provider in Non-billable Domain

    ${domresp}=  Get BusinessDomainsConf
    Log  ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    Set Suite Variable  ${domresp}

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}
        ${subdomain}  ${check}=  Get Non Billable Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Test Variable   ${subdomain}
        Exit For Loop IF     '${check}' == '${bool[0]}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+1321             
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_A}${\n}
    ${licid}  ${licname}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_A}   ${licid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_A}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+666
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+665
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH5}.${test_mail}
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
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
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
    ${resp}=  Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${label}=   FakerLibrary.word
    ${d_note}=   FakerLibrary.word  
    ${resp}=   Enable JDN for Label    ${label}   ${d_note}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['label']}            ${label}
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   0.0
    Should Be Equal As Strings   ${resp.json()['status']}           ${Qstate[0]}

    ${resp}=   Disable JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['label']}            ${label}
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   0.0
    Should Be Equal As Strings   ${resp.json()['status']}           ${Qstate[1]}

JD-TC-DiableJDN-UH1
	[Documentation]  Disable already disabled JDN 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${JDN_DISC_ALREADY_DISABLED}

JD-TC-DiableJDN-UH2
	[Documentation]  Disable JDN without enable JDN

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${JDN_NOT_FOUND}

JD-TC-DiableJDN-UH3
	[Documentation]  Disable JDN without login

    ${resp}=   Disable JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-DiableJDN-UH4
	[Documentation]  Disable JDN with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL} 


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

    
