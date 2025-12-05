from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.db.models import Q
from django.shortcuts import get_object_or_404, redirect, render

from accounts.models import User
from .forms import (
    BienForm,
    BienMediaUploadForm,
    ContractForm,
    InterventionReportForm,
    MessageForm,
    PaymentForm,
    PrestataireAssignmentForm,
)
from .models import Bien, BienMedia, Contract, InterventionReport, Message, Payment, PrestataireAssignment


def home(request):
    prestataires = User.objects.filter(role=User.Role.PRESTATAIRE, marketplace_visible=True)[:4]
    return render(request, "immo/home.html", {"prestataires": prestataires})


@login_required
def dashboard(request):
    user: User = request.user
    context = {}
    if user.is_proprietaire():
        biens = Bien.objects.filter(owner=user)
        contrats = Contract.objects.filter(owner=user).order_by("-created_at")[:5]
        paiements = Payment.objects.filter(
            Q(contract__owner=user) | Q(bien__owner=user)
        ).order_by("-created_at")[:5]
        context.update(
            {
                "biens": biens,
                "contrats": contrats,
                "paiements": paiements,
                "assignments": PrestataireAssignment.objects.filter(bien__owner=user),
            }
        )
    else:
        missions = PrestataireAssignment.objects.filter(prestataire=user, active=True)
        rapports = InterventionReport.objects.filter(prestataire=user).order_by("-created_at")[:5]
        context.update(
            {
                "missions": missions,
                "rapports": rapports,
            }
        )
    last_messages = Message.objects.filter(Q(sender=user) | Q(receiver=user)).order_by("-created_at")[:6]
    context["last_messages"] = last_messages
    return render(request, "immo/dashboard.html", context)


@login_required
def biens_list(request):
    biens = Bien.objects.filter(owner=request.user)
    return render(request, "immo/biens_list.html", {"biens": biens})


@login_required
def bien_create(request):
    if not request.user.is_proprietaire():
        messages.error(request, "Seuls les propriétaires peuvent créer des biens.")
        return redirect("dashboard")
    if request.method == "POST":
        form = BienForm(request.POST)
        if form.is_valid():
            bien = form.save(commit=False)
            bien.owner = request.user
            bien.save()
            messages.success(request, "Bien ajouté.")
            return redirect("biens_list")
    else:
        form = BienForm()
    return render(request, "immo/bien_form.html", {"form": form, "title": "Nouveau bien"})


@login_required
def bien_edit(request, pk):
    bien = get_object_or_404(Bien, pk=pk, owner=request.user)
    if request.method == "POST":
        form = BienForm(request.POST, instance=bien)
        if form.is_valid():
            form.save()
            messages.success(request, "Bien mis à jour.")
            return redirect("biens_list")
    else:
        form = BienForm(instance=bien)
    return render(request, "immo/bien_form.html", {"form": form, "title": "Modifier le bien"})


@login_required
def assign_prestataire(request, pk):
    bien = get_object_or_404(Bien, pk=pk, owner=request.user)
    if request.method == "POST":
        form = PrestataireAssignmentForm(request.POST)
        if form.is_valid():
            assignment, _ = PrestataireAssignment.objects.get_or_create(
                bien=bien, prestataire=form.cleaned_data["prestataire"]
            )
            assignment.active = True
            assignment.save()
            messages.success(request, "Prestataire associé au bien.")
            return redirect("biens_list")
    else:
        form = PrestataireAssignmentForm()
    return render(request, "immo/assign_prestataire.html", {"form": form, "bien": bien})


@login_required
def bien_media(request, pk):
    bien = get_object_or_404(Bien, pk=pk, owner=request.user)
    existing_count = bien.media.count()
    form = BienMediaUploadForm(request.POST or None, request.FILES or None)
    if request.method == "POST" and form.is_valid():
        files = form.cleaned_data["files"]
        if existing_count + len(files) > 10:
            messages.error(request, "Maximum 10 médias par bien.")
        else:
            for f in files:
                BienMedia.objects.create(bien=bien, file=f)
            messages.success(request, "Médias ajoutés.")
            return redirect("bien_media", pk=bien.id)
    medias = bien.media.order_by("-uploaded_at")
    return render(request, "immo/bien_media.html", {"bien": bien, "form": form, "medias": medias, "existing_count": existing_count})


@login_required
def contract_create(request):
    if not request.user.is_proprietaire():
        messages.error(request, "Seuls les propriétaires peuvent créer des contrats.")
        return redirect("dashboard")
    form = ContractForm(request.POST or None)
    form.fields["bien"].queryset = Bien.objects.filter(owner=request.user)
    if request.method == "POST" and form.is_valid():
        contrat: Contract = form.save(commit=False)
        contrat.owner = request.user
        contrat.save()
        messages.success(request, "Contrat enregistré.")
        return redirect("dashboard")
    return render(request, "immo/contract_form.html", {"form": form})


@login_required
def payment_create(request):
    form = PaymentForm(request.POST or None)
    form.fields["contract"].queryset = Contract.objects.filter(owner=request.user) if request.user.is_proprietaire() else Contract.objects.none()
    form.fields["bien"].queryset = Bien.objects.filter(owner=request.user) if request.user.is_proprietaire() else Bien.objects.none()
    form.fields["prestataire"].queryset = User.objects.filter(role=User.Role.PRESTATAIRE)
    if request.method == "POST" and form.is_valid():
        paiement: Payment = form.save()
        messages.success(request, "Paiement enregistré.")
        return redirect("dashboard")
    return render(request, "immo/payment_form.html", {"form": form})


@login_required
def marketplace(request):
    search = request.GET.get("q", "")
    prestataires = User.objects.filter(role=User.Role.PRESTATAIRE, marketplace_visible=True)
    if search:
        prestataires = prestataires.filter(Q(username__icontains=search) | Q(specialization__icontains=search))
    return render(request, "immo/marketplace.html", {"prestataires": prestataires, "search": search})


@login_required
def inbox(request):
    user = request.user
    ids = set()
    for sender_id, receiver_id in Message.objects.filter(Q(sender=user) | Q(receiver=user)).values_list("sender_id", "receiver_id"):
        ids.update([sender_id, receiver_id])
    ids.discard(user.id)
    contacts = User.objects.filter(id__in=ids)
    assignments = PrestataireAssignment.objects.filter(bien__owner=user) if user.is_proprietaire() else PrestataireAssignment.objects.filter(prestataire=user)
    suggested = {a.prestataire for a in assignments} if user.is_proprietaire() else {a.bien.owner for a in assignments}
    return render(
        request,
        "immo/inbox.html",
        {"contacts": contacts, "suggested": suggested},
    )


@login_required
def conversation(request, user_id):
    other = get_object_or_404(User, pk=user_id)
    if request.method == "POST":
        form = MessageForm(request.POST, request.FILES)
        if form.is_valid():
            msg = form.save(commit=False)
            msg.sender = request.user
            msg.receiver = other
            msg.save()
            messages.success(request, "Message envoyé.")
            return redirect("conversation", user_id=other.id)
    else:
        form = MessageForm()
    messages_qs = Message.objects.filter(
        Q(sender=request.user, receiver=other) | Q(sender=other, receiver=request.user)
    ).order_by("created_at")
    return render(request, "immo/conversation.html", {"messages_qs": messages_qs, "other": other, "form": form})


@login_required
def report_create(request):
    if not request.user.is_prestataire():
        messages.error(request, "Seuls les prestataires peuvent déposer un rapport.")
        return redirect("dashboard")
    form = InterventionReportForm(request.POST or None, request.FILES or None)
    form.fields["bien"].queryset = Bien.objects.filter(prestataires__prestataire=request.user, prestataires__active=True)
    if request.method == "POST" and form.is_valid():
        report: InterventionReport = form.save(commit=False)
        report.prestataire = request.user
        report.save()
        messages.success(request, "Rapport transmis au propriétaire.")
        return redirect("dashboard")
    return render(request, "immo/report_form.html", {"form": form})
