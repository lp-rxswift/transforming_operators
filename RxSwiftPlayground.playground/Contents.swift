import Foundation
import RxSwift

//transforming operators

struct Student {
  let score: BehaviorSubject<Int>
}

example(of: "value of flatMap") {
  let string = Observable.of("a", "b", "c")
  string
    .flatMap { Observable.of("\($0)-x", "\($0)-y", "\($0)-z") }
    .subscribe(onNext: { element in
        print(element) // this prints 9 values.
    })
}

example(of: "verbose print element") {
  let string = Observable.of("a", "b", "c")
  string
    .flatMap { element -> Observable<String> in
      return Observable.just(element)
    }
    .subscribe(onNext: { print($0) })
}

example(of: "flat map async") {
  let subject = PublishSubject<URL>()
  let string = Observable.of("a", "b", "c")
  string
    .flatMap { element -> Observable<URL> in
      let url = URL(string: "http://myserver.com/api/get_user?id=\(element)")!
      DispatchQueue.main.async {
        subject.onNext(url)
      }
      return subject.asObserver()
    }
    .subscribe(onNext: { print($0) })
}

example(of: "toArray") {
  let disposeBag = DisposeBag()

  Observable.of("A", "B", "C")
    .toArray()
    .subscribe(onSuccess: { print($0) })
    .disposed(by: disposeBag)
}

example(of: "map") {
  let disposeBag = DisposeBag()

  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut

  Observable<Int>.of(123, 4, 56)
    .map { formatter.string(for: $0) ?? "" }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
}

example(of: "enumerated and map") {
  let disposeBag = DisposeBag()

  Observable.of(1, 2, 3, 4, 5, 6)
    .enumerated()
    .map { index, integer in
      index > 2 ? integer * 2 : integer
    }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
}

example(of: "compact map") {
  let disposeBag = DisposeBag()

  Observable.of("To", "be", nil, "or", "not", "be", nil)
    .compactMap { $0 }
    .toArray()
    .map { $0.joined(separator: " ") }
    .subscribe(onSuccess: { print($0) })
    .disposed(by: disposeBag)
}

example(of: "flat map") {
  let disposeBag = DisposeBag()

  let laura = Student(score: BehaviorSubject(value: 80))
  let charlotte = Student(score: BehaviorSubject(value: 90))

  let student = PublishSubject<Student>()

  student
    .flatMap { $0.score }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)

  student.onNext(laura)
  laura.score.onNext(85)
  student.onNext(charlotte)
  laura.score.onNext(95)
  charlotte.score.onNext(100)
}

example(of: "flat map latest") {
  let disposeBag = DisposeBag()

  let laura = Student(score: BehaviorSubject(value: 80))
  let charlotte = Student(score: BehaviorSubject(value: 90))

  let student = PublishSubject<Student>()

  student
    .flatMapLatest { $0.score }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)

  student.onNext(laura)
  laura.score.onNext(85)
  student.onNext(charlotte)
  laura.score.onNext(95)
  charlotte.score.onNext(100)
}

example(of: "Materialize and Dematerialize") {
  enum MyError: Error {
    case anError
  }

  let disposeBag = DisposeBag()

  let laura = Student(score: BehaviorSubject(value: 80))
  let charlotte = Student(score: BehaviorSubject(value: 100))
  let student = BehaviorSubject(value: laura)

  let studentScore = student.flatMapLatest({ $0.score.materialize() })

//  studentScore
//    .subscribe(onNext: { print($0) })
//    .disposed(by: disposeBag)

  studentScore
    .filter {
      guard $0.error == nil else {
        print($0.error!)
        return false
      }
      return true
    }
    .dematerialize()
    .subscribe(onNext: { print("dematerialized: \($0)") })
    .disposed(by: disposeBag)

  laura.score.onNext(85)
  laura.score.onError(MyError.anError)
  laura.score.onNext(90)
  student.onNext(charlotte)
}
