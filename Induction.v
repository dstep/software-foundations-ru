(** * Индукция: доказательство по индукции *)

(** Прежде, чем начать, нам нужно подключить все наши определения
    из прошлой главы: *)

Require Export Basics.

(** Чтобы команда [Require Export] сработала, вам сперва нужно
    использовать [coqc] чтобы скомпилировать [Basics.v] в [Basics.vo].
    Это -- то же самое, что создать файл .class из .java, или 
    объектный файл .o из .c. Для этого есть два способа:

     - В CoqIDE:

        Откройте файл [Basics.v]. В меню "Compile" выберите пункт
        "Compile Buffer".

     - Из командной строки: либо выполните

        [make Basics.vo]

       (считаем что вы скачали весь репозиторий этой книги, и вам 
       доступна команда 'make'), или

        [coqc Basics.v]

       (что должно сработать в любом окне терминала).

    Если у вас возникли проблемы (например, вы получаете сообщения об
    отсутствующих идентификаторах далее в этом файле), это может 
    означать, что ваш путь загрузки (load path) для Coq не был 
    корректно настроен. Команда [Print LoadPath.] может помочь 
    в разрешении этой проблемы.

    В частности, если вы видите сообщение вроде

      [Compiled library Foo makes inconsistent assumptions over
      library Coq.Init.Bar]

      [Скомпилированная библиотека Foo делает предположения, 
      несовместимые с библиотекой Coq.Init.Bar]
  
    вам следует проверить, не установлено ли на вашей машине несколько
    версий Coq. Если это так, то возможно, что команды (вроде [coqc]),
    которые вы исполняете в терминале, принадлежат версии отличной от
    той, которая используется в Proof General или CoqIDE.

    Еще один совет для пользователей CoqIDE: если вы видите сообщение 

        "Error: Unable to locate library Basics"
        "Ошибка: не могу найти библиотеку Basics"

    вероятная причина - несоответствие при компиляции внутри _CoqIDE_
    и использовании _coqc_ из командной строки. Обычно это происходит,
    когда установлены две несовместимые версии coqc (та, которой 
    пользуется CoqIDE, и та, которая доступна из терминала). Чтобы
    избежать этой проблемы, можно компилировать только из CoqIDE 
    (командой "make" в меню "Compile"), и избегать прямого 
    использования coqc. *)

(* ################################################################# *)
(** * Доказательство по индукции *)

(** В прошлой главе мы доказали, что [0] является нейтральным элементом
    для [+] слева, используя простые рассуждения, основанные на 
    упрощении. Заметим также, что доказательство факта, что [0] также
    является нейтральным элементом справа... *)

Theorem plus_n_O_firsttry : forall n:nat,
  n = n + 0.

(** ... не может быть проведено тем же способом. Простое применение
    тактики [reflexivity] не работает, так как [n] в [n + 0] --
    произвольное неизвестное число, так что выражение [match] в
    определении [+] не может быть упрощено. *)

Proof.
  intros n.
  simpl. (* Ничего не делает! *)
Abort.

(** Рассуждения с использованием анализа случаев [destruct n] также
    не позволяют нам продвинуться: случай, в котором мы приняли
    [n = 0] легко доказывается, но в случае [n = S n'] для некоторого
    [n'] мы застреваем в точно такой же ситуации. *)

Theorem plus_n_O_secondtry : forall n:nat,
  n = n + 0.
Proof.
  intros n. destruct n as [| n'].
  - (* n = 0 *)
    reflexivity. (* пока неплохо... *)
  - (* n = S n' *)
    simpl.       (* ...но здесь мы застряли вновь *)
Abort.

(** Мы могли бы использовать [destruct n'], чтобы продвинуться на
    еще один шаг, но, так как [n] может быть произвольно большим,
    если мы пойдем этим путем, то никогда не закончим. *)

(** Чтобы доказывать интересные факты о числах, списках, и прочих
    индуктивно заданных множествах нам нужен более мощный механизм
    рассуждений: индукция.

    Вспомним (из школьного курса или курса дискретной математики)
    _принцип индукции для натуральных чисел_: если [P(n)] -- некоторое
    утверждение о натуральном числе [n], и мы хотим показать, что [P]
    верно для всех чисел [n], мы можем рассуждать таким образом:
        - показать, что [P(O)] верно
        - показать, что для любого [n'], если [P(n')] верно, то также 
          верно [P(S n')]
        - заключить, что [P(n)] верно для всех [n]

    В Coq эти шаги точно такие же: мы начинаем доказательства 
    утверждения [P(n)] для всех [n], и разбиваем его (при помощи
    тактики [induction]) на две отдельные подцели: в одной мы должны
    показать, что верно [P(O)], в другой -- [P(n') -> P(S n')]. Вот
    как это работает для нашей теоремы: *)

Theorem plus_n_O : forall n:nat, n = n + 0.
Proof.
  intros n. induction n as [| n' IHn'].
  - (* n = 0 *)    reflexivity.
  - (* n = S n' *) simpl. rewrite <- IHn'. reflexivity.  Qed.

(** Как и [destruct], тактика [induction] может иметь блок [as...],
    который задает имена переменных, вводимых подцелями. Так как здесь
    у нас две цели, блок [as...] содержит две части, разделенные [|].
    (Строго говоря, мы можем опустить блок [as...] и Coq выберет имена
    за нас. На практике это плохая идея, поскольку имена, выбираемые
    автоматически, часто сбивают с толку.)

    В первой подцели [n] заменено [0]. Новых переменных не вводилось,
    (поэтому первая часть блока [as...] пуста), и цель приняла вид
    [0 = 0 + 0], что доказывается упрощением. 

    Во второй подцели [n] заменено на [S n'], а в контекст добавлено
    предположение [n' + 0 = n'] с именем [IHn'] (то есть, предположение
    индукции (Induction Hypothesis) для [n']). Эти имена заданы во 
    второй части блока [as...] Цель принимает вид [S n' = (S n') + 0],
    а после упрощения -- [S n' = S (n' + 0)], что следует из гипотезы
    [IHn']. *)

Theorem minus_diag : forall n,
  minus n n = 0.
Proof.
  intros n. induction n as [| n' IHn'].
  - (* n = 0 *)
    simpl. reflexivity.
  - (* n = S n' *)
    simpl. rewrite -> IHn'. reflexivity.  Qed.

(** (Использование тактики [intros] в этих доказательствах на самом 
    деле избыточно. Когда тактика [induction] применяется к цели,
    содержащей обобщенные переменные, она автоматически перенесет их
    в контекст при необходимости.) *)

(** **** Упражнение: 2 звезды, рекомендуется (basic_induction)  *)
(** Докажите следующие утверждения, используя индукцию. Вам могут
    потребоваться результаты, полученные прежде. *)

Theorem mult_0_r : forall n:nat,
  n * 0 = 0.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.
(* GRADE_THEOREM 0.5: mult_0_r *)

Theorem plus_n_Sm : forall n m : nat,
  S (n + m) = n + (S m).
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.
(* GRADE_THEOREM 0.5: plus_n_Sm *)


Theorem plus_comm : forall n m : nat,
  n + m = m + n.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.
(* GRADE_THEOREM 0.5: plus_comm *)

Theorem plus_assoc : forall n m p : nat,
  n + (m + p) = (n + m) + p.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.
(* GRADE_THEOREM 0.5: plus_assoc *)
(** [] *)

(** **** Упражнение: 2 звезды (double_plus)  *)
(** Рассмотрим следующую функцию, которая удваивает свой аргумент: *)

Fixpoint double (n:nat) :=
  match n with
  | O => O
  | S n' => S (S (double n'))
  end.

(** Используйте индукцию, чтобы доказать простой факт о [double]: *)

Lemma double_plus : forall n, double n = n + n .
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.
(** [] *)

(** **** Упражнение: 2 звезды, опциональное (evenb_S)  *)
(** Одно неудобство, связанное с нашим определением [evenb n], состоит
    в том, что оно делает рекурсивный вызов с аргументом [n - 2]. Это
    делает доказательство по индукции более сложным, так как нам 
    нужно предположение индукции о [n - 2]. Следующая лемма делает 
    альтернативное утверждение об [evenb (S n)], которое лучше работает
    с индукцией: *)

Theorem evenb_S : forall n : nat,
  evenb (S n) = negb (evenb n).
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.
(** [] *)

(** **** Упражнение: 1 звезда (destruct_induction)  *)
(** Коротко объясните различие между тактиками [destruct] и [induction].

(* ЗАПОЛНИТЕ *)
*)
(** [] *)

(* ################################################################# *)
(** * Доказательства внутри доказательств *)

(** В Coq, как и в неформальной математике, длинные доказательства
    часто разбиваются на последовательность теорем, в которых 
    доказываемые позже теоремы ссылаются на более ранние результаты.
    Но иногда доказательства требуют некоторых фактов, которые слишком
    тривиальны и имеют слишком мало ценности в общем случае, чтобы
    оформлять их как отдельную теорему. В таких случаях удобным бывает
    просто сформулировать и доказать необходимую "подтеорему" прямо
    в том месте, где она используется. Тактика [assert] (утверждение)
    позволяет нам это сделать. Например, наше доказательство теоремы 
    [mult_0_plus] ссылается на доказанную прежде теорему [plus_O_n]. 
    Вместо этого мы можем использовать команду [assert] чтобы 
    сформулировать и доказать [plus_O_n] на месте: *)

Theorem mult_0_plus' : forall n m : nat,
  (0 + n) * m = n * m.
Proof.
  intros n m.
  assert (H: 0 + n = n). { reflexivity. }
  rewrite -> H.
  reflexivity.  Qed.

(** Тактика [assert] порождает две подцели. Первая - само утверждение.
    Добавив перед ним [H:] мы дали этому утверждению имя [H]. (Мы также
    могли дать утверждению имя с помощью [as], как мы делали с
    командами [destruct] и [induction], то есть [assert (0 + n = n) 
    as H].) Заметьте, что мы окружили доказательство утверждения
    фигурными скобками [{ ... }] для читаемости. Таким образом, когда 
    Coq используется в интерактивном режиме, мы можем легче видеть,
    когда поддоказательство завершено. Вторая цель - та же самая, что
    и была до вызова тактики [assert], кроме того, что в контекст
    добавлено предположение [H], утверждающее, что [0 + n = n]. Таким
    образом, тактика [assert] создает одну подцель, в которой мы должны
    доказать утверждаемый факт, и вторую подцель, в которой мы можем
    использовать утверждаемый факт, чтобы продвинуться в доказательстве
    нашей изначальной цели. *)

(** Другой пример использования [assert]... *)

(** Для примера, предположим, мы хотим доказать, что [(n + m) + (p + q)
    = (m + n) + (p + q)]. Единственным отличием между левой и правой
    частью является то, что аргументы [m] и [n] в первой внутренней
    сумме стоят в другом порядке, и похоже, что мы можем использовать
    коммутативность сложения ([plus_comm]), чтобы переписать левую
    часть в вид, совпадающий с правой частью. Но тактика [rewrite] 
    не очень умна, когда дело доходит до выбора, _где именно_ выполнять
    переписывание. В выражении имеется три применения [+], и
    оказывается, что использование [rewrite -> plus_comm] затронет
    только внешнее... *)

Theorem plus_rearrange_firsttry : forall n m p q : nat,
  (n + m) + (p + q) = (m + n) + (p + q).
Proof.
  intros n m p q.
  (* Нам просто нужно заменить (n + m) на (m + n)... выглядит так,
     будто теорема plus_comm должна помочь! *)
  rewrite -> plus_comm.
  (* Не сработало...Coq переписал другую сумму! *)
Abort.

(** Чтобы использовать [plus_comm] там, где мы хотим, нужно ввести
    локальную лемму, утверждающую, что [n + m = m + n] (для конкретных
    [n] и [m], о которых идет речь), затем доказать эту лемму,
    используя [plus_comm], и воспользоваться ей, чтобы выполнить
    переписывание в нужном месте. *)

Theorem plus_rearrange : forall n m p q : nat,
  (n + m) + (p + q) = (m + n) + (p + q).
Proof.
  intros n m p q.
  assert (H: n + m = m + n).
  { rewrite -> plus_comm. reflexivity. }
  rewrite -> H. reflexivity.  Qed.

(* ################################################################# *)
(** * Формальные и неформальные доказательства *)

(** "_Неформальные доказательства -- алгоритмы; формальные 
    доказательства -- код_." *)

(** Что представляет из себя успешное доказательство математического
    утверждения? Этот вопрос тысячелетиями беспокоил философов, но
    грубое определение может быть таким: доказательство математического
    утверждения [P] -- письменный (или устный) текст, который убеждает
    читателя или слушателя в том, что [P] верно -- неопровержимое 
    свидетельство истинности [P]. Таким образом, доказательство --
    это акт коммуникации.

    В этом акте коммуникации могут участвовать разные читатели. С одной
    стороны, "читателем" может быть программа вроде Coq, в этом случае
    "убеждение", которое внушается -- что [P] может быть механически
    получено из определенного набора формальных логических правил, а
    доказательство -- это рецепт, который ведет программу по пути
    проверки этого факта. Такие рецепты являются _формальными_ 
    доказательствами.

    И напротив, читателем может быть человек. В этом случае 
    доказательство будет записано на английском или другом естественном
    языке, и, как следствие, будет _неформальным_. Критерий успеха
    определены не так явно. "Верное" доказательство -- то, которое 
    заставит читателя поверить в [P]. Но доказательство могут читать
    разные люди. Определенный стиль изложения может убедить одних, но
    не других. Некоторые читатели могут быть особенно педантичными,
    неопытными, или просто не слишком умными. Единственным способом
    убедить их может быть очень тщательно предоставить все детали
    доказательство. Но другие читатели, более искушенные в области,
    могут счесть эти детали настолько отвлекающими, что потеряют
    общую нить размышлений. Все, чего они хотят -- увидеть основную
    идею, так как для них легче додумать детали самостоятельно, чем
    пробираться сквозь подробную их запись. В конечном счете не
    существует универсального стандарта, потому что нет способа записи
    неформального доказательства, которое гарантированно убедит любого
    возможного читателя.

    Тем не менее, на практике математики разработали богатый набор
    соглашений и идиом для описания сложных математических объектов,
    которые (как минимум в определенных кругах) делают общение
    достаточно надежным. Соглашения этой формы коммуникации дают 
    представление о том, как отличать хорошие доказательства от плохих.

    Так как в этом курсе мы используем Coq, мы будем работать 
    преимущественно с формальными доказательствами. Но это не значит,
    что мы можем полностью забыть о неформальных! Формальные 
    доказательства полезны во многих случаях, но они _не являются_
    особенно эффективным способом передачи идей от человека к человеку.
    
    *)

(** Для примера рассмотрим доказательство ассоциативности сложения: *)

Theorem plus_assoc' : forall n m p : nat,
  n + (m + p) = (n + m) + p.
Proof. intros n m p. induction n as [| n' IHn']. reflexivity.
  simpl. rewrite -> IHn'. reflexivity.  Qed.

(** Coq полностью удовлетворен таким доказательством. Однако для 
    человека довольно сложно понять его смысл. Мы можем воспользоваться
    комментариями и маркерами, чтобы показать структуру доказательства
    более явно... *)

Theorem plus_assoc'' : forall n m p : nat,
  n + (m + p) = (n + m) + p.
Proof.
  intros n m p. induction n as [| n' IHn'].
  - (* n = 0 *)
    reflexivity.
  - (* n = S n' *)
    simpl. rewrite -> IHn'. reflexivity.   Qed.

(** ... и если вы хорошо знакомы с Coq, вы можете пройти тактики шаг
    за шагом в вашей голове, и вообразить состояние контекста и цели
    в каждой точке доказательства, но если бы оно было немного более
    сложным, это стало бы почти невозможно проделать.

    Математик (очень педантичный) мог бы записать доказательство
    таким образом: *)

(** - _Теорема_: Для любых [n], [m] и [p],

      n + (m + p) = (n + m) + p.

    _Доказательство_: По индукции на [n].

    - Сначала предположим что [n = 0].  Мы должны показать

        0 + (m + p) = (0 + m) + p.

      Что непосредственно следует из определения [+].

    - Теперь предположим, что [n = S n'], где

        n' + (m + p) = (n' + m) + p.

      Мы должны показать, что

        (S n') + (m + p) = ((S n') + m) + p.

      В определению [+], это следует из

        S (n' + (m + p)) = S ((n' + m) + p),

      что непосредственно следует из предположения индукции.  _Qed_. *)

(** Общая форма доказательства в основном похожа, и, конечно же, это
    не совпадение: Coq разрабатывался таким образом, чтобы тактика
    [induction] производила подцели в том же порядке, в каком бы их
    записал математик. Однако в деталях они различаются существенно:
    формальное доказательство намного более явно говорит о некоторых
    вещах (например, использование тактики [reflexivity]), но намного
    менее явно в других (в частности, "состояние доказательства" в
    каждой точке доказательства Coq полностью скрыто, в то время как
    в неформальном доказательстве мы постоянно напоминаем читателю, 
    что доказывается в данный момент). *)

(** **** Упражнение: 2 звезды, продвинутое, рекомендуется (plus_comm_informal)  *)
(** Запишите ваше доказательство теоремы [plus_comm] в неформальном
    виде:

    Теорема: сложение коммутативно.

    Доказательство: (* ЗАПОЛНИТЕ *)
*)
(** [] *)

(** **** Упражнение: 2 звезды, опциональное (beq_nat_refl_informal)  *)
(** Запишите неформальное доказательство следующей теоремы, используя
    неформальное доказательство [plus_assoc] в качестве модели. Только
    не пересказывайте используемые в Coq тактики русскими словами! 

    Теорема: [true = beq_nat n n] для любого [n].

    Доказательство: (* ЗАПОЛНИТЕ *)
*)
(** [] *)

(* ################################################################# *)
(** * Больше упражнений *)

(** **** Упражнение: 3 звезды, рекомендуется (mult_comm)  *)
(** Используйте тактику [assert], чтобы доказать следующую теорему.
    Вам не потребуется использовать индукцию. *)

Theorem plus_swap : forall n m p : nat,
  n + (m + p) = m + (n + p).
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.

(** Теперь докажите коммутативность умножения. (Скорее всего, вам
    потребуется определить и доказать отдельную вспомогательную
    теорему. Также, доказанная ранее теорема [plus_swap] может 
    оказаться полезной.) *)

Theorem mult_comm : forall m n : nat,
  m * n = n * m.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.
(** [] *)

(** **** Упражнение: 3 звезды, опциональное (more_exercises)  *)
(** Возьмите лист бумаги. Для каждой из следующих теорем, сперва
    _подумайте_ о том (а) может ли она быть доказана, используя только 
    упрощения и переписывания (б) также потребуется анализ случаев 
    ([destruct]), или же (в) потребуется индукция. Запишите свое
    предсказание. Теперь заполните доказательство. (Нет нужды сдавать
    ваш лист с предсказаниями, он нужен, чтобы побудить вас подумать,
    прежде чем пускаться в эксперименты! *)

Check leb.

Theorem leb_refl : forall n:nat,
  true = leb n n.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.

Theorem zero_nbeq_S : forall n:nat,
  beq_nat 0 (S n) = false.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.

Theorem andb_false_r : forall b : bool,
  andb b false = false.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.

Theorem plus_ble_compat_l : forall n m p : nat,
  leb n m = true -> leb (p + n) (p + m) = true.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.

Theorem S_nbeq_0 : forall n:nat,
  beq_nat (S n) 0 = false.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.

Theorem mult_1_l : forall n:nat, 1 * n = n.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.

Theorem all3_spec : forall b c : bool,
    orb
      (andb b c)
      (orb (negb b)
               (negb c))
  = true.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.

Theorem mult_plus_distr_r : forall n m p : nat,
  (n + m) * p = (n * p) + (m * p).
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.

Theorem mult_assoc : forall n m p : nat,
  n * (m * p) = (n * m) * p.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.
(** [] *)

(** **** Упражнение: 2 звезды, опциональное (beq_nat_refl)  *)
(** Докажите следующую теорему. (Помещать [true] слева от знака 
    равенства может показаться странной идеей, но именно таким образом
    эта теорема определена в стандартной библиотеке Coq. Переписывание
    работает одинаково хорошо в обоих направлениях, так что у нас не
    будет проблем с использованием этой теоремы, вне зависимости от
    того, как мы ее сформулируем.) *)

Theorem beq_nat_refl : forall n : nat,
  true = beq_nat n n.
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.
(** [] *)

(** **** Упражнение: 2 звезды, опциональное (plus_swap')  *)
(** Тактика [replace] позволяет указать определенное подвыражение для
    переписывания, и то, чем вы хотите его заменить: [replace (t) with
    (u)] заменит (все вхождения) выражения [t] в текущей цели на [u],
    и создаст новую подцель [t = u]. Это часто может быть полезным,
    когда [rewrite] меняет неправильную часть цели.

    Используйте тактику [replace], чтобы доказать  [plus_swap'], 
    так же, как вы это делали для [plus_swap], но без использования
    [assert (n + m = m + n)]. *)

Theorem plus_swap' : forall n m p : nat,
  n + (m + p) = m + (n + p).
Proof.
  (* ЗАПОЛНИТЕ *) Admitted.
(** [] *)

(** **** Упражнение: 3 stars, рекомендуется (binary_commute)  *)
(** Вспомните функции [incr] и [bin_to_nat], которые вы написали
    для упражнения [binary] из главы [Basics]. Докажите, что
    следующая диаграмма верна:

                            incr
              bin ----------------------> bin
               |                           |
    bin_to_nat |                           |  bin_to_nat
               |                           |
               v                           v
              nat ----------------------> nat
                             S

    То есть, инкремент двоичного числа и преобразование его в унарную 
    запись дает тот же результат, как если бы мы сначала преобразовали
    число, а затем увеличили на один.

    Назовите теорему [bin_to_nat_pres_incr] ("pres" означает 
    "preserves", "сохраняет").

    Прежде, чем начать, скопируйте свое определение двоичных чисел из
    упражнения [binary] сюда, чтобы этот файл можно было оценить
    независимо. Если вам потребуется изменить свое определение, чтобы
    упростить себе доказательство, сделайте это! *)

(* ЗАПОЛНИТЕ *)
(** [] *)

(** **** Упражнение: 5 звезд, продвинутое (binary_inverse)  *)
(** Это упражнение -- продолжение предыдущего упражнения о двоичных
    числах. Вам потребуются ваши определения и теоремы, чтобы выполнить
    его. Пожалуйста, скопируйте их в этот файл, чтобы его можно было
    оценить независимо.

    (a) Во-первых, напишите функцию для преобразования натуральных
        чисел в двоичные числа. Затем докажите, что если взять любое
        натуральное число, преобразовать его в двоичное, а затем
        обратно, то получится изначальное натуральное число.

    (b) Может показаться, что нам следует также доказать обратное 
        утверждение: что если взять двоичное число, преобразовать его
        в натуральное и обратно, то получится изначальное двоичное 
        число. Однако, это неверно! Объясните, в чем здесь проблема.

    (c) Определите прямую функцию нормализации -- то есть функцию
        [normalize] из двоичных чисел в двоичные числа, такую, что
        для любого двоичного числа b, преобразование его в натуральное
        и обратно возвращает результат [(normalize b)]. Докажите это.
        (Предупреждение: эта часть может быть сложной!)

    Опять же, вы можете менять свои прежние определения, если вам это
    поможет. *)

(* ЗАПОЛНИТЕ *)
(** [] *)


(** $Date: 2017-11-15 22:55:41 -0500 (Wed, 15 Nov 2017) $ *)
