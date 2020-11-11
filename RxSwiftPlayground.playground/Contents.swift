import Foundation
import RxSwift

example(of: "toArray") {
  let disposeBag = DisposeBag()

  Observable.of("A", "B", "C")
    .toArray()
    .subscribe(onSuccess: { print($0) })
    .disposed(by: disposeBag)
}
