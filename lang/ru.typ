#import "../template.typ": resume
#import "../settings.typ": clink

#resume(
  name: "Бучнев Вячеслав",
  title: "BACKEND - РАЗРАБОТЧИК",
  contacts: [
    +7(950)128-86-38 \
    slavabuchnev5\@gmail.com \
    tg: \@SlavaBuchnev
  ],
  exp_title: "ОПЫТ РАБОТЫ",
  experience: [
    *Т-Банк BACKEND-РАЗРАБОТЧИК, Т-ID* \
    _май 2025 – настоящее время_
    
    #list(
      [Разработал высоконагруженное REST API для управления учетными записями пользователей для 1M+ пользователей.],
      [Выполнил миграцию данных с Aerospike на PostgreSQL, что повысило надежность хранения и обеспечило консистентность данных.],
      [Провел отладку и исправление ошибок, улучшив стабильность приложения.],
    )
  ],
  proj_title: "ПРОЕКТЫ",
  projects: [
    *Telegram-bot - Учебный проект (Python)*
    #list(
      [Проектирование архитектуры с использованием практик на Python],
      [Проектирование Базы данных],
      [Реализация взаимодействия с БД (PostgreSQL)],
      [Настройка GitHub Actions],
    )
    Репозиторий: \
    #clink("https://github.com/seregabalyuk/TelegramManagerBoardGames")[https://github.com/seregabalyuk/TelegramManagerBoardGames]
  ],
  edu_title: "ОБРАЗОВАНИЕ",
  education: [
    *Иркутский Государственный Университет* \
    _сентябрь 2022 – июль 2026_ \
    прикладная математика и информатика, Бакалавриат
    #v(0.5em)
    
    *Тинькофф образование* \
    _февраль 2024 – май 2024_ \
    Алгоритмы и структуры данных
    #v(0.5em)
    
    *Яндекс алгоритмы* \
    _март 2024_ \
    Тренировки по алгоритмам 5.0
  ],
  port_title: "ПОРТФОЛИО",
  portfolio: [
    #clink("https://github.com/SlavaBuchnev")[https://github.com/SlavaBuchnev]
  ],
  awards_title: "НАГРАДЫ",
  awards: [
    #list(
      [*Стипендиат Т-Банка*, \ Победитель 2025],
      [*Полуфинал ICPC*, \ участник 2024, \ участник 2023, \ участник 2022],
      [*Четвертьфинал ICPC*, \ призер 2024 (4 из 41), \ призер 2023 (4 из 39), \ призер 2022 (10 из 50)],
      [*Летний Контест RuCode*, \ призер 2023 (33 из 231)],
      [*Чемпионат Rucode*, \ призер 2022 (18 из 216)],
    )
  ],
  skills_title: "НАВЫКИ",
  skills: [
    #list(
      [*Scala:* zio, http4s, tapir, doobie],
      [*C++:* STL, Boost],
      [*Python:* Numpy, Requests],
      [*Git*],
      [*SQL:* PostgreSQL],
      [*Linux*],
      [*SOLID*],
    )
  ]
)