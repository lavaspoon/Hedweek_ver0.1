//
//  secondView.swift
//  hedwig ver 0.1
//  Created by lavaspoon on 25/06/2019.
//  Copyright © 2019 lavaspoon. All rights reserved.
//
import UIKit

class secondView : UIViewController{
   
    @IBOutlet weak var joinIdInput: UITextField!
    @IBOutlet weak var joinPwdInput: UITextField!
    
    var databasePath = String()
    
    @IBAction func backBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // < DB 설정 : DB를 사용하기 위해 미리 파일을 구성하고 테입르을 삽입하는 과정 > //
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) // 복잡한 경로 기억하는 함수, 앱의 Document 경로 찾아서 반환해줌
        let docsDir = dirPath[0]
        databasePath = docsDir.appending("/contacts.db")
        // < DB 설정 종료 > //
    }
    
    //여기에 DB 생성해줘
    @IBAction func joinClicked(_ sender: UIButton) {
        
        // < 아이디 중복 확인 > //
        let contactDB = FMDatabase(path: databasePath)
        contactDB.open()
        let selectsql = "SELECT count(*) AS cnt FROM MEMBER WHERE ID = '\(joinIdInput.text!)'"
        do {
            let result = try contactDB.executeQuery(selectsql, values: [])
            if result.next() {
                let count = result.string(forColumn: "cnt")!
                // 아이디가 중복일 때 알림창 띄우기
                if (count != "0") {
                    // < 아이디 중복 알림창 시작> //
                    // alert 변수에 UIAlertController 객체가 할당됨
                    let alert = UIAlertController(
                        title: "알림창",
                        message: "아이디가 중복됩니다. 다른 아이디를 입력해주세요.",
                        preferredStyle: .alert
                    )
                    // alert에서 확인버튼 클릭시
                    let okAction = UIAlertAction(title: "확인", style: .default) {
                        (alert:UIAlertAction!) -> Void in
                        // 입력 안 하면 확인 버튼 클릭 시 그냥 알림창 닫힘
                    }
                    alert.addAction(okAction)
                    present(alert,animated: true, completion: nil)
                    // < 아이디 중복 알림창 종료 > //
                }
                // 아이디가 중복이 아닐 때 가입하기
                else {
                    let sql1 = "INSERT INTO MEMBER VALUES ('\(joinIdInput.text!)', '\(joinPwdInput.text!)', '', '')"
                    if !contactDB.executeStatements(sql1) {
                        NSLog("회원가입 sql 오류")
                    }
                    else {
                        // < 회원가입 완료 알림창 시작> //
                        // alert 변수에 UIAlertController 객체가 할당됨
                        let alert = UIAlertController(
                            title: "알림창",
                            message: "회원가입이 완료되었습니다.",
                            preferredStyle: .alert
                        )
                        // alert에서 확인버튼 클릭시
                        let okAction = UIAlertAction(title: "확인", style: .default) {
                            (alert:UIAlertAction!) -> Void in
                            // 입력 안 하면 확인 버튼 클릭 시 그냥 알림창 닫힘
                        }
                        alert.addAction(okAction)
                        present(alert,animated: true, completion: nil)
                        // < 회원가입 알림창 종료 > //
                    }
                }
                contactDB.close()
            }
        } catch {
            NSLog("ID 조회 DB 오류")
        }
    }
}
