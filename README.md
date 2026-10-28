# Mapa de Locais — Flutter + Firebase Cloud Firestore

Avaliação formativa + tutorial — *Desenvolvimento de Aplicação Mobile com Flutter* (SENAI).
Aplicação de localização: **mapa, pesquisa, resultados e detalhes**.

---

## 1. Descrição da problemática

Uma empresa deseja disponibilizar um aplicativo que permita aos usuários localizar serviços e
estabelecimentos em diferentes cidades. O usuário precisa **selecionar a cidade**, **pesquisar**
o que procura, **filtrar** os resultados, **abrir os detalhes** de um estabelecimento e **marcar
locais como favoritos**. O sistema também deve permitir **cadastrar** novos locais e **alterar**
ou **excluir** os já existentes.

## 2. Objetivo da aplicação

Entregar um aplicativo Flutter, baseado no wireframe da avaliação, em que todos os locais
ficam armazenados no **Cloud Firestore** (e não fixos no código), com as operações
**CRUD** completas, filtros por cidade e categoria, favoritos, navegação entre três telas
e mensagens de sucesso/erro nas operações de banco.

## 3. Requisitos funcionais

| Código | Requisito | Como foi atendido |
|---|---|---|
| RF01 | Selecionar cidade | Seletor na tela do mapa (São Paulo, Campinas, Jundiaí e Limeira) e filtro de cidade na tela de resultados |
| RF02 | Pesquisar | Pesquisa por **nome ou categoria** (`filtrarLocais`) |
| RF03 | Consultar Firestore | `LocalService.listarLocais()` — `StreamBuilder` em tempo real |
| RF04 | Filtrar | Filtro por **categoria** (chips) e por **cidade**, mais o filtro **Favoritos** |
| RF05 | Cadastrar local | Botão "Cadastrar local" → Bottom Sheet → `locais.add()` |
| RF06 | Editar local | Menu do item → mesmo formulário preenchido → `locais.doc(id).update()` |
| RF07 | Excluir local | Menu do item → **diálogo de confirmação** → `locais.doc(id).delete()` |
| RF08 | Detalhes | Tela de detalhes com todas as informações cadastradas |
| RF09 | Favoritar | Coração na tela de detalhes altera o campo `favorito` no documento |
| RF10 | Navegação | Mapa → Resultados → Detalhes → (Ver no mapa) com retorno em todas as telas |

## 4. Requisitos não funcionais

- Desenvolvido em **Flutter/Dart**.
- Banco de dados: **Cloud Firestore**.
- Projeto configurado com **FlutterFire** (`flutterfire configure` → `lib/firebase_options.dart`).
- Interface pensada para **Android**.
- Código organizado em **pastas** (`models`, `services`, `screens`, `widgets`, `dialogs`, `utils`).
- Operações de **exclusão pedem confirmação**.
- **Mensagens de sucesso ou erro** (SnackBar) em todas as operações de banco; estados de
  carregando, erro e lista vazia nas consultas.
- Regras de segurança do Firestore (`firestore.rules`): o banco **não** fica aberto para escrita.

## 5. Tecnologias utilizadas

| Tecnologia | Uso | Obrigatória |
|---|---|---|
| Flutter / Dart | Interface e lógica | Sim |
| Firebase | Backend | Sim |
| Cloud Firestore (`cloud_firestore`) | Banco NoSQL | Sim |
| FlutterFire CLI | Configuração do Firebase no Flutter | Sim |
| Firebase Auth (`firebase_auth`) | Login de administradores (extensão) | Extensão |
| MapLibre GL em `webview_flutter` | Mapa real em 3D (extensão, sem chave de API) | Extensão |

## 6. Arquitetura do projeto

```
lib/
├── main.dart                     # inicializa o Firebase e abre MapaScreen
├── firebase_options.dart         # GERADO pelo `flutterfire configure` (não editar)
├── models/
│   └── local.dart                # modelo Local (fromMap / toMap)
├── services/
│   ├── local_service.dart        # único acesso ao Firestore (CRUD + favorito)
│   ├── filtro_locais.dart        # filtrarLocais() — pesquisa e filtros em memória
│   ├── auth_service.dart         # login/logout (extensão)
│   └── dados_exemplo.dart        # 20 locais de exemplo (5 por cidade)
├── screens/
│   ├── mapa_screen.dart          # Tela 1 — mapa principal
│   ├── resultados_screen.dart    # Tela 2 — lista / resultados / CRUD
│   └── detalhes_screen.dart      # Tela 3 — detalhes do local
├── widgets/
│   ├── local_card.dart           # item da lista
│   ├── local_form.dart           # formulário de cadastro/edição (Bottom Sheet)
│   ├── mapa_web_view.dart        # mapa 3D com marcadores
│   └── barra_navegacao.dart      # barra Mapa / Favoritos / Perfil
├── dialogs/
│   ├── confirm_delete.dart       # confirmação de exclusão
│   └── login_sheet.dart          # login do administrador (Bottom Sheet)
└── utils/                        # constantes, formatadores, mensagens, coordenadas
```

**Princípio:** as telas **nunca** falam direto com o banco — todo acesso passa por `LocalService`.
Cadastro, edição e login aparecem em **Bottom Sheets**; por isso o app tem **somente três telas
principais**. As abas *Favoritos* e *Perfil* da barra inferior não criam telas novas: *Favoritos*
reabre os Resultados já filtrados por favoritos e *Perfil* abre o login/logout em um Bottom Sheet.

## 7. Modelo da coleção `locais`

```
locais
 └── <id gerado automaticamente pelo Firestore>
      ├── nome:       String   "Academia Fitness"
      ├── categoria:  String   "Academia"
      ├── cidade:     String   "São Paulo"
      ├── avaliacao:  Number   4.8
      ├── distancia:  Number   1.2          (km)
      ├── horario:    String   "06:00 - 22:00"
      ├── descricao:  String   "..."
      ├── favorito:   Boolean  false
      ├── latitude:   Number   (opcional — extensão do mapa real)
      └── longitude:  Number   (opcional — extensão do mapa real)
```

## 8. Operações CRUD

| Operação | Firestore | Método no `LocalService` | Onde é usada |
|---|---|---|---|
| Create | `locais.add()` | `adicionar(local)` | Resultados → "Cadastrar local" |
| Read | `locais.snapshots()` | `listarLocais()` / `observarLocal(id)` | Mapa, Resultados, Detalhes |
| Update | `locais.doc(id).update()` | `atualizar(local)` / `alterarFavorito(id, valor)` | Editar (Resultados) e coração (Detalhes) |
| Delete | `locais.doc(id).delete()` | `excluir(id)` | Resultados → menu → confirmação |

Pesquisa e filtros rodam **em memória** (`filtrarLocais`), como na versão didática da seção 16
do documento.

## 9. Segurança (seção 25)

`firestore.rules` (publicar em *Firebase Console → Firestore → Regras*):

- **Leitura:** pública.
- **Criar, editar e excluir:** somente usuário **autenticado** (administrador), com validação
  dos tipos dos campos.
- **Favoritar:** qualquer pessoa pode alterar **apenas** o campo `favorito`.

No app, ao tocar em *Cadastrar*, *Editar* ou *Excluir* sem estar logado, o login é solicitado.
Para criar o administrador: *Firebase Console → Authentication → Método de login → E-mail/senha
(ativar) → Usuários → Adicionar usuário*.

---

## Como executar (tutorial, seções 9 e 10)

```bash
# 1) dentro da pasta do projeto
flutter pub get            # (ou: flutter pub add firebase_core cloud_firestore firebase_auth)

# 2) Firebase CLI e FlutterFire CLI
firebase login
dart pub global activate flutterfire_cli
flutterfire configure      # escolha o projeto e a plataforma Android
                           # → gera lib/firebase_options.dart (substitui o arquivo provisório)

# 3) rodar
flutter run
```

1. No **Firebase Console**, abra *Cloud Firestore* e crie o banco (modo de teste só durante o
   desenvolvimento; depois publique o conteúdo de `firestore.rules`).
2. Ative *Authentication → E-mail/senha* e crie um usuário administrador.
3. Abra o app, entre em **Resultados** e, com a coleção vazia, use
   **"Carregar dados de exemplo (administrador)"** — cria **20 locais** (5 por cidade) na
   coleção `locais`. (Também é possível cadastrar à mão pelo Console.)

> O arquivo `lib/firebase_options.dart` que vem no projeto é **provisório**: enquanto o
> `flutterfire configure` não for executado, o app mostra a tela "Firebase não configurado".

### Testes automatizados

```bash
flutter test
```

Cobrem o modelo (`fromMap`/`toMap`), a pesquisa e os filtros (`filtrarLocais`), os
formatadores e o `LocalCard`. Não dependem do Firebase.

---

## Tabela de testes obrigatórios (seção 26)

> Preencha a coluna **Resultado** após executar cada teste no aparelho/emulador.

| ID | Teste | Procedimento | Resultado |
|---|---|---|---|
| T01 | Conexão | Abrir o aplicativo e verificar se os dados do Firestore aparecem | ☐ Passou ☐ Falhou |
| T02 | Pesquisa | Pesquisar por "Academia" | ☐ Passou ☐ Falhou |
| T03 | Cidade | Selecionar Campinas | ☐ Passou ☐ Falhou |
| T04 | Filtro | Selecionar uma categoria | ☐ Passou ☐ Falhou |
| T05 | Create | Cadastrar um novo local e verificar no Firestore | ☐ Passou ☐ Falhou |
| T06 | Read | Fechar/reabrir a tela e verificar o registro | ☐ Passou ☐ Falhou |
| T07 | Update | Editar nome ou horário e confirmar a alteração | ☐ Passou ☐ Falhou |
| T08 | Delete | Excluir um local e confirmar que desapareceu | ☐ Passou ☐ Falhou |
| T09 | Favorito | Marcar e desmarcar um local | ☐ Passou ☐ Falhou |
| T10 | Navegação | Abrir resultados e detalhes e retornar | ☐ Passou ☐ Falhou |
| T11 | Erro | Simular ausência de dados/erro e verificar mensagem | ☐ Passou ☐ Falhou |

Dicas: **T11** — coloque o aparelho em modo avião (ao salvar, aparece "sem resposta do
servidor") ou filtre por algo inexistente ("Nenhum local encontrado.").
**T02/T03/T04** — a pesquisa e os filtros funcionam sobre os dados lidos do Firestore.

## Capturas de tela e prints (entregáveis)

Adicione as imagens na pasta `docs/prints/` e confira aqui:

- [ ] `docs/prints/tela1_mapa.png` — Tela 1 (Mapa principal)
- [ ] `docs/prints/tela2_resultados.png` — Tela 2 (Resultados)
- [ ] `docs/prints/tela3_detalhes.png` — Tela 3 (Detalhes)
- [ ] `docs/prints/firestore_documentos.png` — Console do Firestore mostrando os documentos da coleção `locais`

## Checklist de entrega (seção 29)

- [ ] Projeto Flutter executando
- [ ] Firebase conectado ao projeto (`flutterfire configure`)
- [ ] Cloud Firestore configurado
- [ ] Coleção `locais` criada
- [ ] Pelo menos 10 locais cadastrados (o botão de exemplo cria 20)
- [x] Tela de mapa implementada
- [x] Tela de resultados implementada
- [x] Tela de detalhes implementada
- [ ] Leitura do Firestore funcionando
- [ ] Cadastro funcionando
- [ ] Edição funcionando
- [ ] Exclusão funcionando
- [ ] Favoritos funcionando
- [ ] Pesquisa funcionando
- [ ] Filtros funcionando
- [ ] Navegação funcionando
- [ ] Testes documentados (tabela acima preenchida)
- [ ] Prints das telas anexados
- [ ] Print do Firestore anexado

*(Os itens sem marcação dependem de executar o app com o seu projeto Firebase.)*

## Desafios extras (seção 28)

| Nível | Desafio | Situação |
|---|---|---|
| 1 | Imagens com Firebase Storage | Não implementado (imagens são *placeholders*, como no wireframe) |
| 2 | Mapa real | **Feito** — mapa 3D (MapLibre + satélite) com um marcador por local |
| 3 | Autenticação | **Feito** — login por e-mail/senha; só autenticados cadastram, editam e excluem |
| 4 | Consultas com `where`/`orderBy` | Não implementado (filtros em memória, versão didática) |
| 5 | Favoritos por usuário | Não implementado (favorito é um campo do documento) |
| 6 | Avaliações pelos usuários | Não implementado |

## Conclusão sobre o desenvolvimento

O aplicativo segue o wireframe proposto, com três telas principais (mapa, resultados e detalhes) e
as operações de cadastro, edição e exclusão feitas em Bottom Sheets e diálogos. Separar o acesso
ao banco em `LocalService` deixou as telas simples e facilitou os testes, porque a pesquisa e os
filtros (`filtrarLocais`) são funções puras. O uso de `StreamBuilder` com `snapshots()` mantém a
lista e a tela de detalhes sempre atualizadas sem recarregar manualmente. As regras de segurança
impedem que qualquer pessoa altere o banco, liberando apenas a leitura e o favorito.
*(Complemente com suas observações após executar os testes.)*

## Referências

- Firebase para Flutter: https://firebase.google.com/docs/flutter/setup
- Cloud Firestore — operações de dados: https://firebase.google.com/docs/firestore/manage-data/add-data
