import Foundation
import RxSwift

struct Student {
  let score: BehaviorSubject<Int>
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
