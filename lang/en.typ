#import "../template.typ": resume
#import "../settings.typ": clink

#resume(
  name: "Vyacheslav Buchnev",
  title: "BACKEND DEVELOPER",
  contacts: [
    +7(950)128-86-38 \
    slavabuchnev5\@gmail.com \
    tg: \@SlavaBuchnev
  ],
  exp_title: "EXPERIENCE",
  experience: [
    *T-Bank BACKEND DEVELOPER, T-ID* \
    _May 2025 – Present_
    
    #list(
      [Developed a high-load REST API for user account management serving 1M+ users.],
      [Migrated data from Aerospike to PostgreSQL, improving storage reliability and ensuring data consistency.],
      [Debugged and fixed bugs, improving application stability.],
    )
  ],
  proj_title: "PROJECTS",
  projects: [
    *Telegram-bot - Educational Project (Python)*
    #list(
      [Architecture design using Python best practices],
      [Database design],
      [Database integration (PostgreSQL)],
      [GitHub Actions setup],
    )
    Repository: \
    #clink("https://github.com/seregabalyuk/TelegramManagerBoardGames")[https://github.com/seregabalyuk/TelegramManagerBoardGames]
  ],
  edu_title: "EDUCATION",
  education: [
    *Irkutsk State University* \
    _September 2022 – July 2026_ \
    Applied Mathematics and Computer Science, Bachelor's degree
    #v(0.5em)
    
    *Tinkoff Education* \
    _February 2024 – May 2024_ \
    Algorithms and Data Structures
    #v(0.5em)
    
    *Yandex Algorithms* \
    _March 2024_ \
    Algorithm Training 5.0
  ],
  port_title: "PORTFOLIO",
  portfolio: [
    #clink("https://github.com/SlavaBuchnev")[https://github.com/SlavaBuchnev]
  ],
  awards_title: "AWARDS",
  awards: [
    #list(
      [*T-Bank Scholarship*, \ Winner 2025],
      [*ICPC Semifinalist*, \ participant 2024, participant 2023, participant 2022],
      [*ICPC Quarterfinalist*, \ winner 2024 (4 out of 41), winner 2023 (4 out of 39), winner 2022 (10 out of 50)],
      [*RuCode Summer Contest*, \ winner 2023 (33 out of 231)],
      [*RuCode Championship*, \ winner 2022 (18 out of 216)],
    )
  ],
  skills_title: "SKILLS",
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