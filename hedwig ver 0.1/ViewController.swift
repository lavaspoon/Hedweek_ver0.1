//
//  ViewController.swift
//  hedwig ver 0.1
//
//  Created by lavaspoon on 25/06/2019.
//  Copyright © 2019 lavaspoon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var uiIdInput: UITextField!
    @IBOutlet var uiPasswordInput: UITextField!
        
    var id = String()
    var password = String()
    
    // DB 저장되는 파일 경로
    var databasePath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // < DB 설정 : DB를 사용하기 위해 미리 파일을 구성하고 테입르을 삽입하는 과정 > //
        
        let fileMgr = FileManager.default // FileManager의 인스턴스 생성
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) // 복잡한 경로 기억하는 함수, 앱의 Document 경로 찾아서 반환해줌
        let docsDir = dirPath[0]
        databasePath = docsDir.appending("/contacts.db")
        
        if !fileMgr.fileExists(atPath: databasePath) { // 파일 존재 여부 판별, 없으면 생성하고 테이블을 구성하는 쿼리 실행
            let contactDB = FMDatabase(path: databasePath) // FMDatabase 클래스의 인스턴스 생성
            
            if contactDB.open() {
                let sql1 = "CREATE TABLE IF NOT EXISTS MEMBER (ID TEXT PRIMARY KEY, PASSWORD TEXT, NAME TEXT, AGE INTEGER)"
                // if not exists test : 테이블이 존재하지 않으면
                // 실행할 쿼리를 sql1 상수에 미리 저장하고 executeStatements로 구문을 실행해 실제 DB 테이블 생성
                let sql2 = "INSERT INTO MEMBER VALUES ('root', '1234', '운영자', '26')"
                if !contactDB.executeStatements(sql1) {
                    NSLog("SQL 오류 1")
                }
                if !contactDB.executeStatements(sql2) {
                    NSLog("SQL 오류 2")
                }
                contactDB.close()
            } else {
                NSLog("contactDB 열기 실패")
            }
        } else {
            NSLog("contactDB가 존재")
        }
        // < DB 설정 종료 > //
    }

    @IBAction func loginClicked(_ sender: Any) {
        
        let userId = uiIdInput.text
        let userPassword = uiPasswordInput.text
        
        // ID 조회
        let contactDB = FMDatabase(path: databasePath)
        contactDB.open()
        let selectsql = "SELECT * FROM MEMBER WHERE ID = '\(userId!)'"
        do {
            let result = try contactDB.executeQuery(selectsql, values: [])
            if result.next() {
                id = result.string(forColumn: "ID")!
                password = result.string(forColumn: "PASSWORD")!
            }
        } catch {
            NSLog("ID 조회 DB 오류")
        }
        // ID 조회
        
        
        
        
        
        //메인메뉴로 가는 객체선언
        let menuScreen = self.storyboard!.instantiateViewController(withIdentifier: "Menu")
        menuScreen.modalTransitionStyle = .coverVertical
        //
        
        
        
        //alert 변수에 UIAlertController 객체가 할당됨
        let alert = UIAlertController(
            title: "알림창",
            message: "아이디: \(userId!), 비밀번호: \(userPassword!)",
            preferredStyle: .alert
        )
        //alert에서 확인버튼 클릭시
        let okAction = UIAlertAction(title: "OK", style: .default){
            (alert:UIAlertAction!) -> Void in
            NSLog("알림 대화상자의 확인 버튼이 눌렸습니다.")
            
            if(userId == self.id) && (userPassword == self.password){
                self.present(menuScreen, animated: true,    completion: nil)
                NSLog("로그인 성공")
            }else{
                NSLog("로그인 실패")
            }
        }
        
        alert.addAction(okAction)
        present(alert,animated: true, completion: nil)
        
    }

}

