***Settings***
Test Teardown    Delete All Sessions
Suite Teardown    Delete All Sessions
Force Tags        Invoice
Library           Collections
Library           String
Library           json
Library         /ebs/TDD/db.py
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Resource        /ebs/TDD/SuperAdminKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***

JD-TC-Invoice-1
    [Documentation]  verify invoice after completing business profile.

    ${resp}=  get_iscorp_subdomains  0
    Set Test Variable  ${dom}  ${resp[0]['domain']}
    Set Test Variable  ${sub_dom}  ${resp[0]['subdomains']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_T}=  Evaluate  ${PUSERNAME}+5566823
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_T}    9
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_T}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_T}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid1}=  get_acc_id  ${PUSERNAME_T}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Invoice Generartion   ${pid1}    ${bool[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_T}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_T}${\n}
    Set Suite Variable  ${PUSERNAME_T}
    ${pid}=  get_acc_id  ${PUSERNAME_T}
    Set Suite Variable  ${pid}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_T}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME_T}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_T}.${test_mail}  ${views}
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
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
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

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
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

    ${licresp}=   Get upgradable license
    Should Be Equal As Strings    ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    # ${index}=  Evaluate  ${liclen}/2

    ${index_list}=  Create List   0  1  2  3  4  
    ${index}=  Random Element    ${index_list}
    Set Suite Variable  ${pkgId}  ${licresp.json()[${index}]['pkgId']}
    Set Suite Variable  ${lprice1}  ${licresp.json()[${index}]['price']}

    ${resp}=  Change License Package  ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${licuuid}   ${resp.json()[0]['ynwUuid']}
    Set Suite Variable  ${cGstPct}   ${resp.json()[0]['cGstPct']}
    Set Suite Variable  ${sGstPct}   ${resp.json()[0]['sGstPct']}
    ${gst_pct}=  Evaluate  ${cGstPct}+${sGstPct}
    Set Suite Variable  ${gst_pct}
    ${amt_with_cgst}=  Evaluate  ${lprice1}*${cGstPct}/100
    ${amt_with_sgst}=  Evaluate  ${lprice1}*${sGstPct}/100
    ${amt_with_gst}=  Evaluate  ${lprice1}*${gst_pct}/100
    ${total_amt_with_gst}=  Evaluate  ${amt_with_gst}+${lprice1}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${createdDate}  ${DAY1}
    ${DAY2}=  bill_cycle
    Set Suite Variable  ${DAY2}
    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${createdDate}  periodFrom=${createdDate}  periodTo=${DAY2}  amount=${resp.json()[0]['licensePkgDetails']['amount']}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=${bool[0]}  balance=0.0
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}
    Should Be Equal As Strings  ${resp.json()[0]['cGstAmt']}  ${amt_with_cgst}
    Should Be Equal As Strings  ${resp.json()[0]['sGstAmt']}  ${amt_with_sgst}
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${len}=  Evaluate  ${len}-1
    ${len}=  Set Variable If  ${len}<0  0  ${len}
    ${lp}=  commaformatNumber  ${total_amt_with_gst}
    ${SUBSCRIPTION_FEE_ALERT_MSG}=  Format String  ${SUBSCRIPTION_FEE_ALERT_MSG}  ${lp} 
    Should Be Equal As Strings  ${resp.json()[${len}]['text']}  ${SUBSCRIPTION_FEE_ALERT_MSG}
    Should Be Equal As Strings  ${resp.json()[${len}]['subject']}    ${SUBSCRIPTION_FEE_ALERT_SUBJECT}

JD-TC-Invoice-2
    [Documentation]   invoice after addon
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_T}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Alert  ${pid}
    ${resp}=   Get Addons Metadata
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${aId}  ${resp.json()[0]['addons'][0]['addonId']}
    Set Suite Variable  ${aprice}  ${resp.json()[0]['addons'][0]['price']}
    ${resp}=  Add addon  ${aId} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    ${amount}=  Evaluate  ${lprice1}+${aprice}
    ${amt_with_cgst}=  Evaluate  ${amount}*${cGstPct}/100
    ${amt_with_sgst}=  Evaluate  ${amount}*${sGstPct}/100
    ${amt_with_gst}=  Evaluate  ${amount}*${gst_pct}/100
    ${total_amt_with_gst}=  Evaluate  ${amt_with_gst}+${amount}
    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${createdDate}  periodFrom=${createdDate}  periodTo=${DAY2}  amount=${amount}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=False  balance=${lprice1}
    Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${aId}
    Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['amount']}  ${aprice}
    Should Be Equal As Strings  ${resp.json()[0]['cGstAmt']}  ${amt_with_cgst}
    Should Be Equal As Strings  ${resp.json()[0]['sGstAmt']}  ${amt_with_sgst}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['accountId']}  ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['ynwUuid']}  ${licuuid}
    
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${len}=  Evaluate  ${len}-1
    ${len}=  Set Variable If  ${len}<0  0  ${len}

    ${lp}=  commaformatNumber  ${total_amt_with_gst}
    ${SUBSCRIPTION_FEE_ALERT_MSG}=  Format String  ${SUBSCRIPTION_FEE_ALERT_MSG}  ${lp}
    Should Be Equal As Strings  ${resp.json()[${len}]['text']}  ${SUBSCRIPTION_FEE_ALERT_MSG}
    Should Be Equal As Strings  ${resp.json()[${len}]['subject']}    ${SUBSCRIPTION_FEE_ALERT_SUBJECT}

JD-TC-Invoice-3
    [Documentation]   get invoices after payment
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_T}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Invoices  NotPaid
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Set Test Variable  ${uid}  ${resp.json()[0]['ynwUuid']}
    pay_invoice  ${uid}
    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  0
    ${resp}=  Get Invoices  Paid
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    ${amount}=  Evaluate  ${lprice1}+${aprice}
    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${createdDate}  periodFrom=${createdDate}  periodTo=${DAY2}  amount=${amount}  licensePaymentStatus=Paid  debit=0.0  credit=0.0  periodic=False  balance=${lprice1}
    Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${aId}
    Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['amount']}  ${aprice}

JD-TC-Invoice-4
    [Documentation]  verify multiple invoices

    ${resp}=  get_iscorp_subdomains  0
    Set Test Variable  ${dom}  ${resp[0]['domain']}
    Set Test Variable  ${sub_dom}  ${resp[0]['subdomains']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_S}=  Evaluate  ${PUSERNAME}+5564501
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_S}    9
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_S}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_S}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${ph}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Invoice Generartion   ${pid1}    ${bool[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_S}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_S}${\n}
    Set Suite Variable  ${PUSERNAME_S}
    ${pid}=  get_acc_id  ${PUSERNAME_S}
    Set Suite Variable  ${pid}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_S}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME_S}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_S}.${test_mail}  ${views}
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
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
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

    ${resp}=  Enable Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
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

    ${licresp}=   Get upgradable license
    Should Be Equal As Strings    ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    # ${index}=  Evaluate  ${liclen}/2
    ${index_list}=  Create List   0  1  2  3  4  
    ${index}=  Random Element    ${index_list}
    Set Suite Variable  ${pkgId}  ${licresp.json()[${index}]['pkgId']}
    Set Suite Variable  ${lprice1}  ${licresp.json()[${index}]['price']}

    ${resp}=  Change License Package  ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${licuuid}   ${resp.json()[0]['ynwUuid']}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${createdDate}  ${DAY1}
    ${DAY2}=  bill_cycle
    ${amt_with_cgst}=  Evaluate  ${lprice1}*${cGstPct}/100
    ${amt_with_sgst}=  Evaluate  ${lprice1}*${sGstPct}/100
    ${amt_with_gst}=  Evaluate  ${lprice1}*${gst_pct}/100
    ${total_amt_with_gst}=  Evaluate  ${amt_with_gst}+${lprice1}
    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${createdDate}  periodFrom=${createdDate}  periodTo=${DAY2}  amount=${resp.json()[0]['licensePkgDetails']['amount']}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=${bool[0]}  balance=0.0
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}
    Should Be Equal As Strings  ${resp.json()[0]['cGstAmt']}  ${amt_with_cgst}
    Should Be Equal As Strings  ${resp.json()[0]['sGstAmt']}  ${amt_with_sgst}
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${len}=  Evaluate  ${len}-1
    ${len}=  Set Variable If  ${len}<0  0  ${len}
    ${lp}=  commaformatNumber  ${total_amt_with_gst}
    ${SUBSCRIPTION_FEE_ALERT_MSG1}=  Format String  ${SUBSCRIPTION_FEE_ALERT_MSG}  ${lp} 
    Should Be Equal As Strings  ${resp.json()[${len}]['text']}  ${SUBSCRIPTION_FEE_ALERT_MSG1}
    Should Be Equal As Strings  ${resp.json()[${len}]['subject']}    ${SUBSCRIPTION_FEE_ALERT_SUBJECT}
    pay_invoice  ${licuuid}
    clear_Alert  ${pid}
    ${resp}=   Get Addons Metadata
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${aId}  ${resp.json()[0]['addons'][0]['addonId']}
    Set Suite Variable  ${aprice}  ${resp.json()[0]['addons'][0]['price']}
    ${resp}=  Add addon  ${aId} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${createdDate}  periodFrom=${createdDate}  periodTo=${DAY2}  amount=${aprice}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=False  balance=0.0
    Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${aId}
    Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['amount']}  ${aprice}
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${len}=  Evaluate  ${len}-1
    ${len}=  Set Variable If  ${len}<0  0  ${len}
    ${total_amt_with_gst}=  Evaluate  ${aprice}*${gst_pct}/100
    ${total_amt_with_gst}=  Evaluate  ${total_amt_with_gst}+${aprice}
    ${ap}=  commaformatNumber  ${total_amt_with_gst}
    ${SUBSCRIPTION_FEE_ALERT_MSG2}=  Format String  ${SUBSCRIPTION_FEE_ALERT_MSG}  ${ap}
    Should Be Equal As Strings  ${resp.json()[${len}]['text']}  ${SUBSCRIPTION_FEE_ALERT_MSG2}
    Should Be Equal As Strings  ${resp.json()[${len}]['subject']}    ${SUBSCRIPTION_FEE_ALERT_SUBJECT}


JD-TC-Invoice-UH1
    [Documentation]  get invoice without login
    ${resp}=  Get Invoices  NotPaid
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Invoice-UH2
    [Documentation]  get invoice using consumer login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Invoices  Paid
    Should Be Equal As Strings   ${resp.status_code}   401 
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Invoice-UH3
    [Documentation]  verify invoice after signup
    ${resp}=  get_iscorp_subdomains  0
    Set Test Variable  ${d1}  ${resp[0]['domain']}
    Set Test Variable  ${sd1}  ${resp[0]['subdomains']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph}=  Evaluate  ${PUSERNAME7}+728542
    Set Suite Variable  ${ph}
    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    # ${index}=  Evaluate  ${liclen}/2
    ${index_list}=  Create List   0  1  2  3  4  
    ${index}=  Random Element    ${index_list}
    Set Suite Variable  ${pkgId}  ${licresp.json()[${index}]['pkgId']}
    Set Suite Variable  ${lprice1}  ${licresp.json()[${index}]['price']}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ph}   ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph}${\n}
    ${pid1}=  get_acc_id  ${ph}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Invoice Generartion   ${pid1}    ${bool[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accStatus']}       ${status[3]}
    ${pid}=  get_acc_id  ${ph}
    Set Suite Variable  ${pid}
    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}        []

*** Comments ***
JD-TC-Invoice-5
    [Documentation]  Apply SC discount at signup

    ${resp}=  SuperAdmin Login  ${SUSERNAME}   ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_config}=  Get SC Configuration
    Log  ${resp_config.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${providerDiscDuration}   ${resp_config.json()['defaultProJaldeeDiscDuration']}
    Set Test Variable  ${providerDiscFromJaldee}  ${resp_config.json()['defaultProDiscFromJaldee']}
    Set Test Variable  ${commissionPct}  ${resp_config.json()['defaultComModelPct']}
    Set Test Variable  ${commissionDuration}  ${resp_config.json()['comModelMaxTillMonth']}
    Set Test Variable  ${id}   ${resp_config.json()['bonusRates'][0]['id']}
    Set Test Variable  ${targetCount}   ${resp_config.json()['bonusRates'][0]['targetCount']}
    Set Test Variable  ${rate}   ${resp_config.json()['bonusRates'][0]['rate']}

    ${resp_accnt_config}=  Get SCAccount Configuration
    Log  ${resp_accnt_config.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bonusPeriod}  ${resp_accnt_config.json()['scBonusPeriodDetails'][0]['value']}
    Set Test Variable  ${scType}  ${resp_accnt_config.json()['scTypeDetails'][0]['value']}

    ${radiusCoverage}  Random Int  min=0   max=10
    ${scId}=  db.Generate_ScId
    ${scName}  FakerLibrary.name
    ${contactFirstName}   FakerLibrary.first_name
    ${contactLastName}   FakerLibrary.last_name
    ${address}   db.get_address
    ${city}  db.get_place
    ${metro}   db.get_place
    ${state}   db.get_place
    ${privateNote}  FakerLibrary.name
    ${pincodesCoverage}  FakerLibrary.postcode
    ${primaryPhoneNo}=  Evaluate  ${PUSERNAME19}+5001 
    ${altPhoneNo1}=   Evaluate  ${PUSERNAME19}+5002
    ${altPhoneNo2}=  Evaluate  ${PUSERNAME19}+5003
    ${latitude}  get_latitude
    ${longitude}  get_longitude
    ${providerDiscFromJaldee}=  Convert To Number  ${providerDiscFromJaldee}  0 
    ${commissionPct}=  Convert To Number  ${commissionPct}  0
    clear_ScTable  ${primaryPhoneNo} 
    Set Test Variable  ${PrimaryEmail}    ${primaryPhoneNo}.${test_mail}
    Set Test Variable  ${altEmail2}   ${altPhoneNo2}.${test_mail}
    Set Test Variable  ${altEmail1}   ${altPhoneNo1}.${test_mail}
    
    ${resp}=  Create SA SalesChannel  ${scId}  ${providerDiscFromJaldee}  ${providerDiscDuration}  ${scName}   ${contactFirstName}  ${contactLastName}  ${address}   ${city}  ${metro}   ${state}   ${latitude}   ${longitude}   ${radiusCoverage}   ${pincodesCoverage}   ${scType}   ${primaryPhoneNo}   ${altPhoneNo1}   ${altPhoneNo2}   ${commissionDuration}   ${commissionPct}   ${PrimaryEmail}   ${altEmail1}   ${altEmail2}   ${bonusPeriod}   ${id}  ${targetCount}   ${rate}  ${privateNote}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${respo}=  SuperAdminKeywords.Get SalesChannel By Id  ${ScId}
    Log  ${respo.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp_config.json()['scDiscCodes']}
    ${len}=  Evaluate  ${len}-1
    ${index1}=  Random Int  min=0   max=${len}
    ${month}=  Random Int  min=2   max=12
    Set Test Variable  ${scCode}  ${scId}-${resp_config.json()['scDiscCodes'][${index1}]['code']}${month}-0-0
    Log  ${scCode}

    ${resp}=  get_iscorp_subdomains  0
    Set Test Variable  ${dom}  ${resp[0]['domain']}
    Set Test Variable  ${sub_dom}  ${resp[0]['subdomains']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_R}=  Evaluate  ${PUSERNAME19}+5001
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_R}    9
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_R}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${scwtype}=  Random Element  ${HowDoYouHear}
    ${resp}=  Create HowDoYouHearUs  ${PUSERNAME_R}  ${scwtype}  ${scCode}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_R}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_R}${\n}
    Set Suite Variable  ${PUSERNAME_R}
    ${pid}=  get_acc_id  ${PUSERNAME_R}
    Set Suite Variable  ${pid}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_R}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME_R}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_R}.${test_mail}  ${views}
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
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
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

    ${resp}=  Enable Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
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

    ${licresp}=   Get upgradable license
    Should Be Equal As Strings    ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    # ${index}=  Evaluate  ${liclen}/2
    ${index_list}=  Create List   0  1  2  3  4  
    ${index}=  Random Element    ${index_list}
    Set Suite Variable  ${pkgId}  ${licresp.json()[${index}]['pkgId']}
    Set Suite Variable  ${lprice1}  ${licresp.json()[${index}]['price']}

    ${resp}=  Change License Package  ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  get_iscorp_subdomains  0
    # Set Test Variable  ${d1}  ${resp[0]['domain']}
    # Set Test Variable  ${sd1}  ${resp[0]['subdomains']}
    # ${firstname}=  FakerLibrary.first_name
    # ${lastname}=  FakerLibrary.last_name
    # ${ph}=  Evaluate  ${PUSERNAME7}+72002
    # ${licresp}=   Get Licensable Packages
    # Should Be Equal As Strings   ${licresp.status_code}   200
    # ${liclen}=  Get Length  ${licresp.json()}
    # ${licindex}=  Evaluate  ${liclen}/2
    # Set Test Variable  ${pkgId}  ${licresp.json()[${licindex}]['pkgId']}
    # Set Test Variable  ${lprice1}  ${licresp.json()[${licindex}]['price']}
    # ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ph}   ${pkgId}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Activation  ${ph}  0
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${scwtype}=  Random Element  ${HowDoYouHear}
    # ${resp}=  Create HowDoYouHearUs  ${ph}  ${scwtype}  ${scCode}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph}${\n}
    # ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${pid}=  get_acc_id  ${ph}
    ${resp}=  Get Invoices  NotPaid 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${licuuid}   ${resp.json()[0]['ynwUuid']}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  bill_cycle
    Set Test Variable  ${scdiscpct}  ${resp_config.json()['scDiscCodes'][${index1}]['value']}
    ${scdiscpct}=  Convert To Number  ${scdiscpct}  1
    ${discJD}=  Evaluate  float(${lprice1}*${providerDiscFromJaldee}/100)
    ${discJD}=  Convert To Number  ${discJD}  2
    ${scdiscappamnt}=  Evaluate  ${lprice1}-${discJD}
    ${discSC}=  Evaluate  float(${scdiscappamnt}*${scdiscpct}/100)
    ${discSC}=  Convert To Number  ${discSC}  2
    ${amount}=  Evaluate  ${lprice1}-${discSC}-${discJD}

    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${DAY1}  periodFrom=${DAY1}  periodTo=${DAY2}  amount=${amount}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=${bool[0]}  balance=0.0  providerDiscAmtByJaldee=${discJD}  providerDiscAmtBySc=${discSC}   providerDiscPctByJaldee=${providerDiscFromJaldee}  providerDiscPctBySc=${scdiscpct}  jaldeeDiscAppliedAmt=${lprice1}  scDiscAppliedAmt=${scdiscappamnt}  scDiscAppliedMonths=1  jaldeeDiscAppliedMonths=1
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}
    

